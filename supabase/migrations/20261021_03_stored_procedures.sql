-- ==============================================================================
-- STORED PROCEDURES & SECURE PRIVILEGED FUNCTIONS
-- Dialect: PostgreSQL 15+ (Supabase)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. REDEEM INVITATION AND CREATE MEMBERSHIP REQUEST
-- Atomic operation executed by an authenticated user with an invitation token hash
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.redeem_invitation_and_request(
    p_code_hash TEXT,
    p_note TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_invitation RECORD;
    v_request_id UUID;
    v_user_id UUID := auth.uid();
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Authentication required.';
    END IF;

    -- Find matching valid invitation
    SELECT * INTO v_invitation
    FROM public.invitations
    WHERE code_hash = p_code_hash
      AND is_revoked = FALSE
      AND expires_at > timezone('utc', now())
      AND redeemed_at IS NULL
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid, expired, or already redeemed invitation code.';
    END IF;

    -- Check if user is already a member
    IF EXISTS (
        SELECT 1 FROM public.family_memberships
        WHERE family_id = v_invitation.family_id
          AND user_id = v_user_id
    ) THEN
        RAISE EXCEPTION 'You are already a member of this family archive.';
    END IF;

    -- Check if pending request exists
    IF EXISTS (
        SELECT 1 FROM public.membership_requests
        WHERE family_id = v_invitation.family_id
          AND user_id = v_user_id
          AND status = 'pending'
    ) THEN
        RAISE EXCEPTION 'You already have a pending membership request for this family.';
    END IF;

    -- Mark invitation as redeemed
    UPDATE public.invitations
    SET redeemed_by = v_user_id,
        redeemed_at = timezone('utc', now())
    WHERE id = v_invitation.id;

    -- Insert membership request
    INSERT INTO public.membership_requests (
        family_id,
        user_id,
        invitation_id,
        note,
        status
    ) VALUES (
        v_invitation.family_id,
        v_user_id,
        v_invitation.id,
        p_note,
        'pending'
    )
    RETURNING id INTO v_request_id;

    -- Record audit log
    INSERT INTO public.audit_logs (
        family_id,
        actor_id,
        action,
        entity_type,
        entity_id,
        payload
    ) VALUES (
        v_invitation.family_id,
        v_user_id,
        'request_membership',
        'membership_requests',
        v_request_id,
        jsonb_build_object('invitation_id', v_invitation.id)
    );

    RETURN jsonb_build_object(
        'success', true,
        'request_id', v_request_id,
        'family_id', v_invitation.family_id,
        'status', 'pending'
    );
END;
$$;

-- ------------------------------------------------------------------------------
-- 2. APPROVE MEMBERSHIP REQUEST (Primary Admin Only)
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.approve_membership_request(
    p_request_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_req RECORD;
    v_admin_id UUID := auth.uid();
BEGIN
    SELECT * INTO v_req
    FROM public.membership_requests
    WHERE id = p_request_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Membership request not found.';
    END IF;

    -- Verify caller is primary admin of this family
    IF NOT public.is_family_admin(v_req.family_id) THEN
        RAISE EXCEPTION 'Unauthorized: Only the primary admin can approve membership requests.';
    END IF;

    IF v_req.status <> 'pending' THEN
        RAISE EXCEPTION 'Request is already processed (%s).', v_req.status;
    END IF;

    -- Mark request approved
    UPDATE public.membership_requests
    SET status = 'approved',
        reviewed_by = v_admin_id,
        reviewed_at = timezone('utc', now()),
        updated_at = timezone('utc', now())
    WHERE id = p_request_id;

    -- Insert or activate family membership as viewer
    INSERT INTO public.family_memberships (
        family_id,
        user_id,
        role,
        status,
        joined_at
    ) VALUES (
        v_req.family_id,
        v_req.user_id,
        'viewer',
        'active',
        timezone('utc', now())
    )
    ON CONFLICT (family_id, user_id)
    DO UPDATE SET
        status = 'active',
        role = 'viewer',
        updated_at = timezone('utc', now());

    -- Audit log
    INSERT INTO public.audit_logs (
        family_id,
        actor_id,
        action,
        entity_type,
        entity_id,
        payload
    ) VALUES (
        v_req.family_id,
        v_admin_id,
        'approve_member',
        'membership_requests',
        p_request_id,
        jsonb_build_object('approved_user_id', v_req.user_id)
    );

    RETURN jsonb_build_object('success', true, 'status', 'approved');
END;
$$;

-- ------------------------------------------------------------------------------
-- 3. REJECT MEMBERSHIP REQUEST (Primary Admin Only)
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.reject_membership_request(
    p_request_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_req RECORD;
    v_admin_id UUID := auth.uid();
BEGIN
    SELECT * INTO v_req
    FROM public.membership_requests
    WHERE id = p_request_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Membership request not found.';
    END IF;

    IF NOT public.is_family_admin(v_req.family_id) THEN
        RAISE EXCEPTION 'Unauthorized: Only the primary admin can reject membership requests.';
    END IF;

    UPDATE public.membership_requests
    SET status = 'rejected',
        reviewed_by = v_admin_id,
        reviewed_at = timezone('utc', now()),
        updated_at = timezone('utc', now())
    WHERE id = p_request_id;

    INSERT INTO public.audit_logs (
        family_id,
        actor_id,
        action,
        entity_type,
        entity_id,
        payload
    ) VALUES (
        v_req.family_id,
        v_admin_id,
        'reject_member',
        'membership_requests',
        p_request_id,
        jsonb_build_object('rejected_user_id', v_req.user_id)
    );

    RETURN jsonb_build_object('success', true, 'status', 'rejected');
END;
$$;

-- ------------------------------------------------------------------------------
-- 4. REVOKE MEMBERSHIP (Primary Admin Only)
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.revoke_membership(
    p_membership_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_mem RECORD;
    v_admin_id UUID := auth.uid();
BEGIN
    SELECT * INTO v_mem
    FROM public.family_memberships
    WHERE id = p_membership_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Membership record not found.';
    END IF;

    IF NOT public.is_family_admin(v_mem.family_id) THEN
        RAISE EXCEPTION 'Unauthorized: Only the primary admin can revoke family members.';
    END IF;

    IF v_mem.role = 'primary_admin' THEN
        RAISE EXCEPTION 'The primary admin membership cannot be revoked.';
    END IF;

    UPDATE public.family_memberships
    SET status = 'revoked',
        updated_at = timezone('utc', now())
    WHERE id = p_membership_id;

    INSERT INTO public.audit_logs (
        family_id,
        actor_id,
        action,
        entity_type,
        entity_id,
        payload
    ) VALUES (
        v_mem.family_id,
        v_admin_id,
        'revoke_membership',
        'family_memberships',
        p_membership_id,
        jsonb_build_object('revoked_user_id', v_mem.user_id)
    );

    RETURN jsonb_build_object('success', true, 'status', 'revoked');
END;
$$;

-- ------------------------------------------------------------------------------
-- 5. EXPORT FAMILY ARCHIVE (Full JSON backup for primary admin)
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.export_family_archive(
    p_family_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_export JSONB;
BEGIN
    IF NOT public.is_family_admin(p_family_id) THEN
        RAISE EXCEPTION 'Unauthorized: Only the primary admin can export the family archive.';
    END IF;

    SELECT jsonb_build_object(
        'exported_at', timezone('utc', now()),
        'version', '1.0.0',
        'family', (SELECT row_to_json(f) FROM (SELECT id, name, motto, description, origin_place, created_at FROM public.families WHERE id = p_family_id) f),
        'persons', (SELECT coalesce(jsonb_agg(row_to_json(p)), '[]'::jsonb) FROM (SELECT * FROM public.persons WHERE family_id = p_family_id) p),
        'relationships', (SELECT coalesce(jsonb_agg(row_to_json(r)), '[]'::jsonb) FROM (SELECT * FROM public.relationships WHERE family_id = p_family_id) r),
        'life_events', (SELECT coalesce(jsonb_agg(row_to_json(e)), '[]'::jsonb) FROM (SELECT * FROM public.life_events WHERE family_id = p_family_id) e),
        'event_person_links', (SELECT coalesce(jsonb_agg(row_to_json(l)), '[]'::jsonb) FROM (SELECT * FROM public.event_person_links WHERE family_id = p_family_id) l),
        'sources', (SELECT coalesce(jsonb_agg(row_to_json(s)), '[]'::jsonb) FROM (SELECT * FROM public.sources WHERE family_id = p_family_id) s),
        'media_assets', (SELECT coalesce(jsonb_agg(row_to_json(m)), '[]'::jsonb) FROM (SELECT id, storage_path, media_type, title, description, captured_date, mime_type, file_size_bytes, created_at FROM public.media_assets WHERE family_id = p_family_id) m)
    ) INTO v_export;

    RETURN v_export;
END;
$$;
