-- ==============================================================================
-- FAMILY LEGACY DATABASE SCHEMA
-- Version: 1.0.0
-- Dialect: PostgreSQL 15+ (Supabase)
-- ==============================================================================

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ------------------------------------------------------------------------------
-- CUSTOM ENUM TYPES
-- ------------------------------------------------------------------------------
DO $$ BEGIN
    CREATE TYPE member_role AS ENUM ('primary_admin', 'viewer');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE member_status AS ENUM ('active', 'revoked');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE request_status AS ENUM ('pending', 'approved', 'rejected');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE gender_type AS ENUM ('male', 'female', 'other', 'unknown');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE relationship_type AS ENUM ('parent', 'child', 'spouse', 'sibling');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE media_type AS ENUM ('photo', 'video', 'audio', 'document');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE event_type AS ENUM (
        'birth',
        'marriage',
        'death',
        'migration',
        'education',
        'achievement',
        'residence',
        'custom'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- ------------------------------------------------------------------------------
-- 1. USER PROFILES (links to Supabase auth.users)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    display_name TEXT,
    avatar_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- ------------------------------------------------------------------------------
-- 2. FAMILIES
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.families (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    motto TEXT,
    description TEXT,
    origin_place TEXT,
    created_by UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- ------------------------------------------------------------------------------
-- 3. FAMILY MEMBERSHIPS
-- Rule: Exactly ONE primary_admin per family
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.family_memberships (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    family_id UUID NOT NULL REFERENCES public.families(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    role member_role NOT NULL DEFAULT 'viewer',
    status member_status NOT NULL DEFAULT 'active',
    joined_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    CONSTRAINT uq_family_user UNIQUE (family_id, user_id)
);

-- Enforce exactly one active primary admin per family
CREATE UNIQUE INDEX IF NOT EXISTS uq_one_primary_admin_per_family
    ON public.family_memberships (family_id)
    WHERE (role = 'primary_admin' AND status = 'active');

-- ------------------------------------------------------------------------------
-- 4. INVITATIONS
-- Single-use, expiring, random invitation tokens (stored hashed)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.invitations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    family_id UUID NOT NULL REFERENCES public.families(id) ON DELETE CASCADE,
    code_hash TEXT NOT NULL UNIQUE,
    recipient_email TEXT,
    created_by UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    expires_at TIMESTAMPTZ NOT NULL,
    is_revoked BOOLEAN NOT NULL DEFAULT FALSE,
    redeemed_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    redeemed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- ------------------------------------------------------------------------------
-- 5. MEMBERSHIP REQUESTS
-- Must be explicitly approved by primary admin
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.membership_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    family_id UUID NOT NULL REFERENCES public.families(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    invitation_id UUID REFERENCES public.invitations(id) ON DELETE SET NULL,
    note TEXT,
    status request_status NOT NULL DEFAULT 'pending',
    reviewed_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    CONSTRAINT uq_pending_user_family UNIQUE (family_id, user_id, status)
);

-- ------------------------------------------------------------------------------
-- 6. PERSONS (Canonical Family Member Records)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.persons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    family_id UUID NOT NULL REFERENCES public.families(id) ON DELETE CASCADE,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    preferred_name TEXT,
    maiden_name TEXT,
    alternate_names TEXT[] DEFAULT '{}'::TEXT[],
    gender gender_type NOT NULL DEFAULT 'unknown',
    birth_date DATE,
    birth_date_approx BOOLEAN NOT NULL DEFAULT FALSE,
    birth_year_approx INTEGER,
    birth_place TEXT,
    death_date DATE,
    death_date_approx BOOLEAN NOT NULL DEFAULT FALSE,
    death_year_approx INTEGER,
    death_place TEXT,
    is_living BOOLEAN NOT NULL DEFAULT TRUE,
    bio TEXT,
    life_story TEXT,
    portrait_url TEXT,
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    generation_hint INTEGER,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

CREATE INDEX IF NOT EXISTS idx_persons_family ON public.persons(family_id);
CREATE INDEX IF NOT EXISTS idx_persons_names ON public.persons(family_id, last_name, first_name);

-- ------------------------------------------------------------------------------
-- 7. RELATIONSHIPS
-- Direct graph edge definitions between canonical persons
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.relationships (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    family_id UUID NOT NULL REFERENCES public.families(id) ON DELETE CASCADE,
    person_id UUID NOT NULL REFERENCES public.persons(id) ON DELETE CASCADE,
    related_person_id UUID NOT NULL REFERENCES public.persons(id) ON DELETE CASCADE,
    relationship_type relationship_type NOT NULL,
    start_date DATE,
    end_date DATE,
    notes TEXT,
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    CONSTRAINT chk_no_self_relation CHECK (person_id <> related_person_id),
    CONSTRAINT uq_person_relationship UNIQUE (family_id, person_id, related_person_id, relationship_type)
);

CREATE INDEX IF NOT EXISTS idx_relationships_family ON public.relationships(family_id);
CREATE INDEX IF NOT EXISTS idx_relationships_person ON public.relationships(person_id);
CREATE INDEX IF NOT EXISTS idx_relationships_related ON public.relationships(related_person_id);

-- ------------------------------------------------------------------------------
-- 8. MEDIA ASSETS (Private bucket files metadata)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.media_assets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    family_id UUID NOT NULL REFERENCES public.families(id) ON DELETE CASCADE,
    storage_path TEXT NOT NULL,
    storage_bucket TEXT NOT NULL DEFAULT 'family-legacy-private',
    media_type media_type NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    captured_date DATE,
    captured_date_approx BOOLEAN NOT NULL DEFAULT FALSE,
    mime_type TEXT,
    file_size_bytes BIGINT,
    uploader_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

CREATE INDEX IF NOT EXISTS idx_media_family ON public.media_assets(family_id);

-- ------------------------------------------------------------------------------
-- 9. PERSON MEDIA LINKS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.person_media (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    family_id UUID NOT NULL REFERENCES public.families(id) ON DELETE CASCADE,
    person_id UUID NOT NULL REFERENCES public.persons(id) ON DELETE CASCADE,
    media_asset_id UUID NOT NULL REFERENCES public.media_assets(id) ON DELETE CASCADE,
    is_primary_portrait BOOLEAN NOT NULL DEFAULT FALSE,
    tag TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    CONSTRAINT uq_person_media UNIQUE (person_id, media_asset_id)
);

-- ------------------------------------------------------------------------------
-- 10. LIFE EVENTS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.life_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    family_id UUID NOT NULL REFERENCES public.families(id) ON DELETE CASCADE,
    event_type event_type NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    event_date DATE,
    event_date_approx BOOLEAN NOT NULL DEFAULT FALSE,
    event_year_approx INTEGER,
    location TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

CREATE INDEX IF NOT EXISTS idx_life_events_family ON public.life_events(family_id);

-- ------------------------------------------------------------------------------
-- 11. EVENT PERSON LINKS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.event_person_links (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    family_id UUID NOT NULL REFERENCES public.families(id) ON DELETE CASCADE,
    event_id UUID NOT NULL REFERENCES public.life_events(id) ON DELETE CASCADE,
    person_id UUID NOT NULL REFERENCES public.persons(id) ON DELETE CASCADE,
    role TEXT DEFAULT 'principal',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    CONSTRAINT uq_event_person UNIQUE (event_id, person_id)
);

-- ------------------------------------------------------------------------------
-- 12. SOURCES & CITATIONS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.sources (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    family_id UUID NOT NULL REFERENCES public.families(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    citation TEXT NOT NULL,
    repository TEXT,
    url TEXT,
    source_type TEXT DEFAULT 'record',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

CREATE TABLE IF NOT EXISTS public.person_sources (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    family_id UUID NOT NULL REFERENCES public.families(id) ON DELETE CASCADE,
    person_id UUID NOT NULL REFERENCES public.persons(id) ON DELETE CASCADE,
    source_id UUID NOT NULL REFERENCES public.sources(id) ON DELETE CASCADE,
    citation_detail TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    CONSTRAINT uq_person_source UNIQUE (person_id, source_id)
);

-- ------------------------------------------------------------------------------
-- 13. AUDIT LOGS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    family_id UUID NOT NULL REFERENCES public.families(id) ON DELETE CASCADE,
    actor_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id UUID NOT NULL,
    payload JSONB DEFAULT '{}'::JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

CREATE INDEX IF NOT EXISTS idx_audit_family ON public.audit_logs(family_id, created_at DESC);
