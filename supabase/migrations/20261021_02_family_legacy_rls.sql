-- ==============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES & SECURITY GUARDS
-- Dialect: PostgreSQL 15+ (Supabase)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- HELPER FUNCTIONS FOR SECURITY ENFORCEMENT
-- ------------------------------------------------------------------------------

-- 1. Check if the authenticated user is the active primary_admin of a family
CREATE OR REPLACE FUNCTION public.is_family_admin(f_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.family_memberships fm
        WHERE fm.family_id = f_id
          AND fm.user_id = auth.uid()
          AND fm.role = 'primary_admin'
          AND fm.status = 'active'
    );
$$;

-- 2. Check if the authenticated user is an active approved member of a family
CREATE OR REPLACE FUNCTION public.is_approved_family_member(f_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.family_memberships fm
        WHERE fm.family_id = f_id
          AND fm.user_id = auth.uid()
          AND fm.status = 'active'
    );
$$;

-- 3. Check for ancestry cycles (prevent person from becoming an ancestor of themselves)
CREATE OR REPLACE FUNCTION public.check_ancestry_cycle(
    p_family_id UUID,
    p_parent_id UUID,
    p_child_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    cycle_detected BOOLEAN := FALSE;
BEGIN
    IF p_parent_id = p_child_id THEN
        RETURN TRUE;
    END IF;

    -- Recursive CTE checking if child_id is already an ancestor of parent_id
    WITH RECURSIVE ancestors AS (
        SELECT person_id AS current_ancestor
        FROM public.relationships
        WHERE family_id = p_family_id
          AND related_person_id = p_parent_id
          AND relationship_type = 'child'
        UNION
        SELECT r.person_id
        FROM public.relationships r
        INNER JOIN ancestors a ON r.related_person_id = a.current_ancestor
        WHERE r.family_id = p_family_id
          AND r.relationship_type = 'child'
    )
    SELECT EXISTS (
        SELECT 1 FROM ancestors WHERE current_ancestor = p_child_id
    ) INTO cycle_detected;

    RETURN cycle_detected;
END;
$$;

-- Trigger to validate relationship before insert or update
CREATE OR REPLACE FUNCTION public.validate_relationship_insert()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.person_id = NEW.related_person_id THEN
        RAISE EXCEPTION 'A person cannot have a relationship with themselves.';
    END IF;

    IF NEW.relationship_type = 'parent' THEN
        -- If NEW.person_id is parent of NEW.related_person_id
        IF public.check_ancestry_cycle(NEW.family_id, NEW.person_id, NEW.related_person_id) THEN
            RAISE EXCEPTION 'Cycle detected: This relationship would make a person their own ancestor.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_validate_relationship ON public.relationships;
CREATE TRIGGER trg_validate_relationship
    BEFORE INSERT OR UPDATE ON public.relationships
    FOR EACH ROW
    EXECUTE FUNCTION public.validate_relationship_insert();

-- ------------------------------------------------------------------------------
-- ENABLE RLS ON ALL TABLES
-- ------------------------------------------------------------------------------
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.families ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.family_memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.membership_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.persons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.relationships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.media_assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.person_media ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.life_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_person_links ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sources ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.person_sources ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- ------------------------------------------------------------------------------
-- PROFILES POLICIES
-- ------------------------------------------------------------------------------
CREATE POLICY "Users can view their own profile and profiles of co-family members"
    ON public.profiles FOR SELECT
    USING (
        id = auth.uid() OR
        EXISTS (
            SELECT 1 FROM public.family_memberships fm1
            JOIN public.family_memberships fm2 ON fm1.family_id = fm2.family_id
            WHERE fm1.user_id = auth.uid()
              AND fm2.user_id = public.profiles.id
              AND fm1.status = 'active'
              AND fm2.status = 'active'
        )
    );

CREATE POLICY "Users can update their own profile"
    ON public.profiles FOR UPDATE
    USING (id = auth.uid());

CREATE POLICY "Users can insert their own profile"
    ON public.profiles FOR INSERT
    WITH CHECK (id = auth.uid());

-- ------------------------------------------------------------------------------
-- FAMILIES POLICIES
-- ------------------------------------------------------------------------------
CREATE POLICY "Active members can view family"
    ON public.families FOR SELECT
    USING (public.is_approved_family_member(id) OR created_by = auth.uid());

CREATE POLICY "Any authenticated user can create a family (initial setup)"
    ON public.families FOR INSERT
    WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Only primary admin can update family details"
    ON public.families FOR UPDATE
    USING (public.is_family_admin(id))
    WITH CHECK (public.is_family_admin(id));

CREATE POLICY "Only primary admin can delete family"
    ON public.families FOR DELETE
    USING (public.is_family_admin(id));

-- ------------------------------------------------------------------------------
-- FAMILY MEMBERSHIPS POLICIES
-- ------------------------------------------------------------------------------
CREATE POLICY "Active members can view family memberships"
    ON public.family_memberships FOR SELECT
    USING (public.is_approved_family_member(family_id) OR user_id = auth.uid());

CREATE POLICY "Only primary admin can insert memberships (except creator initial membership)"
    ON public.family_memberships FOR INSERT
    WITH CHECK (
        public.is_family_admin(family_id) OR
        (user_id = auth.uid() AND NOT EXISTS (
            SELECT 1 FROM public.family_memberships WHERE family_id = family_memberships.family_id
        ))
    );

CREATE POLICY "Only primary admin can update memberships (change status/revoke)"
    ON public.family_memberships FOR UPDATE
    USING (public.is_family_admin(family_id))
    WITH CHECK (public.is_family_admin(family_id));

CREATE POLICY "Only primary admin can delete memberships"
    ON public.family_memberships FOR DELETE
    USING (public.is_family_admin(family_id));

-- ------------------------------------------------------------------------------
-- INVITATIONS POLICIES
-- ------------------------------------------------------------------------------
CREATE POLICY "Primary admin can view family invitations"
    ON public.invitations FOR SELECT
    USING (public.is_family_admin(family_id));

CREATE POLICY "Authenticated users can lookup an invitation code to request membership"
    ON public.invitations FOR SELECT
    USING (auth.uid() IS NOT NULL AND is_revoked = FALSE AND expires_at > now());

CREATE POLICY "Only primary admin can insert invitations"
    ON public.invitations FOR INSERT
    WITH CHECK (public.is_family_admin(family_id));

CREATE POLICY "Only primary admin can update invitations"
    ON public.invitations FOR UPDATE
    USING (public.is_family_admin(family_id))
    WITH CHECK (public.is_family_admin(family_id));

-- ------------------------------------------------------------------------------
-- MEMBERSHIP REQUESTS POLICIES
-- ------------------------------------------------------------------------------
CREATE POLICY "Primary admin or requester can view requests"
    ON public.membership_requests FOR SELECT
    USING (public.is_family_admin(family_id) OR user_id = auth.uid());

CREATE POLICY "Authenticated users can submit a membership request"
    ON public.membership_requests FOR INSERT
    WITH CHECK (auth.uid() = user_id AND status = 'pending');

CREATE POLICY "Only primary admin can review/update requests"
    ON public.membership_requests FOR UPDATE
    USING (public.is_family_admin(family_id))
    WITH CHECK (public.is_family_admin(family_id));

-- ------------------------------------------------------------------------------
-- PERSONS POLICIES
-- ------------------------------------------------------------------------------
CREATE POLICY "Approved members can read persons"
    ON public.persons FOR SELECT
    USING (public.is_approved_family_member(family_id));

CREATE POLICY "Only primary admin can insert persons"
    ON public.persons FOR INSERT
    WITH CHECK (public.is_family_admin(family_id));

CREATE POLICY "Only primary admin can update persons"
    ON public.persons FOR UPDATE
    USING (public.is_family_admin(family_id))
    WITH CHECK (public.is_family_admin(family_id));

CREATE POLICY "Only primary admin can delete persons"
    ON public.persons FOR DELETE
    USING (public.is_family_admin(family_id));

-- ------------------------------------------------------------------------------
-- RELATIONSHIPS POLICIES
-- ------------------------------------------------------------------------------
CREATE POLICY "Approved members can read relationships"
    ON public.relationships FOR SELECT
    USING (public.is_approved_family_member(family_id));

CREATE POLICY "Only primary admin can insert relationships"
    ON public.relationships FOR INSERT
    WITH CHECK (public.is_family_admin(family_id));

CREATE POLICY "Only primary admin can update relationships"
    ON public.relationships FOR UPDATE
    USING (public.is_family_admin(family_id))
    WITH CHECK (public.is_family_admin(family_id));

-- ------------------------------------------------------------------------------
-- MEDIA ASSETS & PERSON MEDIA POLICIES
-- ------------------------------------------------------------------------------
CREATE POLICY "Approved members can read media assets"
    ON public.media_assets FOR SELECT
    USING (public.is_approved_family_member(family_id));

CREATE POLICY "Only primary admin can insert media assets"
    ON public.media_assets FOR INSERT
    WITH CHECK (public.is_family_admin(family_id));

CREATE POLICY "Only primary admin can update media assets"
    ON public.media_assets FOR UPDATE
    USING (public.is_family_admin(family_id))
    WITH CHECK (public.is_family_admin(family_id));

CREATE POLICY "Only primary admin can delete media assets"
    ON public.media_assets FOR DELETE
    USING (public.is_family_admin(family_id));

CREATE POLICY "Approved members can read person media links"
    ON public.person_media FOR SELECT
    USING (public.is_approved_family_member(family_id));

CREATE POLICY "Only primary admin can manage person media links"
    ON public.person_media FOR ALL
    USING (public.is_family_admin(family_id))
    WITH CHECK (public.is_family_admin(family_id));

-- ------------------------------------------------------------------------------
-- LIFE EVENTS & EVENT PERSON LINKS POLICIES
-- ------------------------------------------------------------------------------
CREATE POLICY "Approved members can read life events"
    ON public.life_events FOR SELECT
    USING (public.is_approved_family_member(family_id));

CREATE POLICY "Only primary admin can manage life events"
    ON public.life_events FOR ALL
    USING (public.is_family_admin(family_id))
    WITH CHECK (public.is_family_admin(family_id));

CREATE POLICY "Approved members can read event person links"
    ON public.event_person_links FOR SELECT
    USING (public.is_approved_family_member(family_id));

CREATE POLICY "Only primary admin can manage event person links"
    ON public.event_person_links FOR ALL
    USING (public.is_family_admin(family_id))
    WITH CHECK (public.is_family_admin(family_id));

-- ------------------------------------------------------------------------------
-- SOURCES POLICIES
-- ------------------------------------------------------------------------------
CREATE POLICY "Approved members can read sources"
    ON public.sources FOR SELECT
    USING (public.is_approved_family_member(family_id));

CREATE POLICY "Only primary admin can manage sources"
    ON public.sources FOR ALL
    USING (public.is_family_admin(family_id))
    WITH CHECK (public.is_family_admin(family_id));

CREATE POLICY "Approved members can read person sources"
    ON public.person_sources FOR SELECT
    USING (public.is_approved_family_member(family_id));

CREATE POLICY "Only primary admin can manage person sources"
    ON public.person_sources FOR ALL
    USING (public.is_family_admin(family_id))
    WITH CHECK (public.is_family_admin(family_id));

-- ------------------------------------------------------------------------------
-- AUDIT LOGS POLICIES
-- ------------------------------------------------------------------------------
CREATE POLICY "Only primary admin can read audit logs"
    ON public.audit_logs FOR SELECT
    USING (public.is_family_admin(family_id));

CREATE POLICY "Audit logs can be written by system/admin"
    ON public.audit_logs FOR INSERT
    WITH CHECK (auth.uid() = actor_id AND public.is_approved_family_member(family_id));

-- ------------------------------------------------------------------------------
-- SUPABASE STORAGE RLS POLICIES FOR PRIVATE BUCKET 'family-legacy-private'
-- ------------------------------------------------------------------------------
-- Insert bucket creation if not exists
INSERT INTO storage.buckets (id, name, public)
VALUES ('family-legacy-private', 'family-legacy-private', false)
ON CONFLICT (id) DO NOTHING;

-- Read policy: only approved family members can access media in their family folder
-- Storage path structure: <family_id>/<media_asset_id>.<ext>
CREATE POLICY "Allow approved family members to read private media"
    ON storage.objects FOR SELECT
    USING (
        bucket_id = 'family-legacy-private'
        AND public.is_approved_family_member((storage.foldername(name))[1]::UUID)
    );

-- Write policy: only primary admin can upload to private family folder
CREATE POLICY "Allow primary admin to upload private media"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'family-legacy-private'
        AND public.is_family_admin((storage.foldername(name))[1]::UUID)
    );

-- Delete policy: only primary admin can delete private media
CREATE POLICY "Allow primary admin to delete private media"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'family-legacy-private'
        AND public.is_family_admin((storage.foldername(name))[1]::UUID)
    );
