-- ==============================================================================
-- 10-GENERATION SYNTHETIC TEST SEED (For Development, Verification & Staging)
-- Dialect: PostgreSQL 15+ (Supabase)
-- NOTE: Synthetic test data demonstrating 10 generations of living heritage.
-- ==============================================================================

DO $$
DECLARE
    v_admin_id UUID;
    v_family_id UUID;
    v_gen1_father UUID; v_gen1_mother UUID;
    v_gen2_father UUID; v_gen2_mother UUID;
    v_gen3_father UUID; v_gen3_mother UUID;
    v_gen4_father UUID; v_gen4_mother UUID;
    v_gen5_father UUID; v_gen5_mother UUID;
    v_gen6_father UUID; v_gen6_mother UUID;
    v_gen7_father UUID; v_gen7_mother UUID;
    v_gen8_father UUID; v_gen8_mother UUID;
    v_gen9_father UUID; v_gen9_mother UUID;
    v_gen10_child UUID;
BEGIN
    -- Select first profile or fallback
    SELECT id INTO v_admin_id FROM public.profiles LIMIT 1;
    IF v_admin_id IS NULL THEN
        RAISE NOTICE 'No profile found. Please register a user first before running seed.';
        RETURN;
    END IF;

    -- Create family if not exists
    INSERT INTO public.families (name, motto, description, origin_place, created_by)
    VALUES (
        'The Kensington Heritage',
        'Radices Altae, Rami Fortes (Deep Roots, Strong Branches)',
        'An unbroken ten-generation family record chronicling four centuries across three continents.',
        'Edinburgh, Scotland',
        v_admin_id
    ) RETURNING id INTO v_family_id;

    -- Admin membership
    INSERT INTO public.family_memberships (family_id, user_id, role, status)
    VALUES (v_family_id, v_admin_id, 'primary_admin', 'active')
    ON CONFLICT (family_id, user_id) DO NOTHING;

    -- Generation 1 (1720)
    INSERT INTO public.persons (family_id, first_name, last_name, gender, birth_date, death_date, is_living, birth_place, death_place, bio, life_story, is_verified, generation_hint)
    VALUES (v_family_id, 'Archibald', 'Kensington', 'male', '1720-04-12', '1792-11-04', false, 'Edinburgh, Scotland', 'Stirling, Scotland', 'Master stone mason and founder of the family guild.', 'Archibald established the Scottish stone quarry works that supported five successive generations.', true, 1)
    RETURNING id INTO v_gen1_father;

    INSERT INTO public.persons (family_id, first_name, last_name, maiden_name, gender, birth_date, death_date, is_living, birth_place, death_place, bio, is_verified, generation_hint)
    VALUES (v_family_id, 'Margaret', 'Kensington', 'MacLeod', 'female', '1724-08-19', '1801-02-14', false, 'Isle of Skye, Scotland', 'Edinburgh, Scotland', 'Highland herbalist and keeper of clan records.', true, 1)
    RETURNING id INTO v_gen1_mother;

    -- Gen 1 relationship
    INSERT INTO public.relationships (family_id, person_id, related_person_id, relationship_type, is_verified)
    VALUES (v_family_id, v_gen1_father, v_gen1_mother, 'spouse', true);

    -- Generation 2 (1755)
    INSERT INTO public.persons (family_id, first_name, last_name, gender, birth_date, death_date, is_living, birth_place, death_place, bio, is_verified, generation_hint)
    VALUES (v_family_id, 'Hamish', 'Kensington', 'male', '1755-06-10', '1828-09-21', false, 'Edinburgh, Scotland', 'Aberdeen, Scotland', 'Naval architect and merchant mariner.', true, 2)
    RETURNING id INTO v_gen2_father;

    INSERT INTO public.persons (family_id, first_name, last_name, maiden_name, gender, birth_date, death_date, is_living, birth_place, death_place, bio, is_verified, generation_hint)
    VALUES (v_family_id, 'Isla', 'Kensington', 'Sinclair', 'female', '1760-03-15', '1835-12-01', false, 'Orkney, Scotland', 'Aberdeen, Scotland', 'Artist and botanical illustrator.', true, 2)
    RETURNING id INTO v_gen2_mother;

    INSERT INTO public.relationships (family_id, person_id, related_person_id, relationship_type, is_verified) VALUES
    (v_family_id, v_gen1_father, v_gen2_father, 'parent', true),
    (v_family_id, v_gen1_mother, v_gen2_father, 'parent', true),
    (v_family_id, v_gen2_father, v_gen2_mother, 'spouse', true);

    -- Generation 3 (1790)
    INSERT INTO public.persons (family_id, first_name, last_name, gender, birth_date, death_date, is_living, birth_place, death_place, bio, is_verified, generation_hint)
    VALUES (v_family_id, 'Callum', 'Kensington', 'male', '1790-01-22', '1863-04-18', false, 'Aberdeen, Scotland', 'Montreal, Canada', 'Pioneer surveyor who charted early Canadian waterway transit.', true, 3)
    RETURNING id INTO v_gen3_father;

    INSERT INTO public.persons (family_id, first_name, last_name, maiden_name, gender, birth_date, death_date, is_living, birth_place, death_place, bio, is_verified, generation_hint)
    VALUES (v_family_id, 'Elspeth', 'Kensington', 'Campbell', 'female', '1794-09-30', '1870-07-11', false, 'Inverness, Scotland', 'Montreal, Canada', 'Teacher and founder of bilingual community schools.', true, 3)
    RETURNING id INTO v_gen3_mother;

    INSERT INTO public.relationships (family_id, person_id, related_person_id, relationship_type, is_verified) VALUES
    (v_family_id, v_gen2_father, v_gen3_father, 'parent', true),
    (v_family_id, v_gen2_mother, v_gen3_father, 'parent', true),
    (v_family_id, v_gen3_father, v_gen3_mother, 'spouse', true);

    -- Generation 4 (1825)
    INSERT INTO public.persons (family_id, first_name, last_name, gender, birth_date, death_date, is_living, birth_place, death_place, bio, is_verified, generation_hint)
    VALUES (v_family_id, 'Robert', 'Kensington', 'male', '1825-11-14', '1902-08-05', false, 'Montreal, Canada', 'Boston, USA', 'Railway civil engineer during the transcontinental expansion.', true, 4)
    RETURNING id INTO v_gen4_father;

    INSERT INTO public.persons (family_id, first_name, last_name, maiden_name, gender, birth_date, death_date, is_living, birth_place, death_place, bio, is_verified, generation_hint)
    VALUES (v_family_id, 'Beatrice', 'Kensington', 'Tremblay', 'female', '1831-05-18', '1910-01-20', false, 'Quebec City, Canada', 'Boston, USA', 'Pianist and patron of classical chamber arts.', true, 4)
    RETURNING id INTO v_gen4_mother;

    INSERT INTO public.relationships (family_id, person_id, related_person_id, relationship_type, is_verified) VALUES
    (v_family_id, v_gen3_father, v_gen4_father, 'parent', true),
    (v_family_id, v_gen3_mother, v_gen4_father, 'parent', true),
    (v_family_id, v_gen4_father, v_gen4_mother, 'spouse', true);

    -- Generation 5 (1860)
    INSERT INTO public.persons (family_id, first_name, last_name, gender, birth_date, death_date, is_living, birth_place, death_place, bio, is_verified, generation_hint)
    VALUES (v_family_id, 'Charles', 'Kensington', 'male', '1860-07-04', '1934-10-12', false, 'Boston, USA', 'New York, USA', 'Professor of Natural Philosophy and early telegraphic telegraphist.', true, 5)
    RETURNING id INTO v_gen5_father;

    INSERT INTO public.persons (family_id, first_name, last_name, maiden_name, gender, birth_date, death_date, is_living, birth_place, death_place, bio, is_verified, generation_hint)
    VALUES (v_family_id, 'Clara', 'Kensington', 'Fairchild', 'female', '1865-02-28', '1945-09-03', false, 'Providence, USA', 'New York, USA', 'Astronomer and observatory researcher.', true, 5)
    RETURNING id INTO v_gen5_mother;

    INSERT INTO public.relationships (family_id, person_id, related_person_id, relationship_type, is_verified) VALUES
    (v_family_id, v_gen4_father, v_gen5_father, 'parent', true),
    (v_family_id, v_gen4_mother, v_gen5_father, 'parent', true),
    (v_family_id, v_gen5_father, v_gen5_mother, 'spouse', true);

    -- Generation 6 (1895)
    INSERT INTO public.persons (family_id, first_name, last_name, gender, birth_date, death_date, is_living, birth_place, death_place, bio, is_verified, generation_hint)
    VALUES (v_family_id, 'Arthur', 'Kensington', 'male', '1895-03-12', '1971-06-25', false, 'New York, USA', 'London, UK', 'World War I medical corps doctor and surgeon.', true, 6)
    RETURNING id INTO v_gen6_father;

    INSERT INTO public.persons (family_id, first_name, last_name, maiden_name, gender, birth_date, death_date, is_living, birth_place, death_place, bio, is_verified, generation_hint)
    VALUES (v_family_id, 'Evelyn', 'Kensington', 'Vane', 'female', '1900-11-09', '1988-03-19', false, 'London, UK', 'London, UK', 'Nurse administrator and public health advocate.', true, 6)
    RETURNING id INTO v_gen6_mother;

    INSERT INTO public.relationships (family_id, person_id, related_person_id, relationship_type, is_verified) VALUES
    (v_family_id, v_gen5_father, v_gen6_father, 'parent', true),
    (v_family_id, v_gen5_mother, v_gen6_father, 'parent', true),
    (v_family_id, v_gen6_father, v_gen6_mother, 'spouse', true);

    -- Generation 7 (1930)
    INSERT INTO public.persons (family_id, first_name, last_name, gender, birth_date, death_date, is_living, birth_place, death_place, bio, is_verified, generation_hint)
    VALUES (v_family_id, 'Julian', 'Kensington', 'male', '1930-10-18', '2012-01-08', false, 'London, UK', 'San Francisco, USA', 'Aeronautical engineer and glider pilot.', true, 7)
    RETURNING id INTO v_gen7_father;

    INSERT INTO public.persons (family_id, first_name, last_name, maiden_name, gender, birth_date, death_date, is_living, birth_place, death_place, bio, is_verified, generation_hint)
    VALUES (v_family_id, 'Helena', 'Kensington', 'Alvarez', 'female', '1935-08-22', '2021-04-14', false, 'Madrid, Spain', 'San Francisco, USA', 'Architectural historian and preservationist.', true, 7)
    RETURNING id INTO v_gen7_mother;

    INSERT INTO public.relationships (family_id, person_id, related_person_id, relationship_type, is_verified) VALUES
    (v_family_id, v_gen6_father, v_gen7_father, 'parent', true),
    (v_family_id, v_gen6_mother, v_gen7_father, 'parent', true),
    (v_family_id, v_gen7_father, v_gen7_mother, 'spouse', true);

    -- Generation 8 (1962)
    INSERT INTO public.persons (family_id, first_name, last_name, gender, birth_date, is_living, birth_place, bio, is_verified, generation_hint)
    VALUES (v_family_id, 'David', 'Kensington', 'male', '1962-09-05', true, 'San Francisco, USA', 'Software systems architect and documentary archivist.', true, 8)
    RETURNING id INTO v_gen8_father;

    INSERT INTO public.persons (family_id, first_name, last_name, maiden_name, gender, birth_date, is_living, birth_place, bio, is_verified, generation_hint)
    VALUES (v_family_id, 'Sophia', 'Kensington', 'Sterling', 'female', '1966-12-14', true, 'Seattle, USA', 'Botanist and alpine conservationist.', true, 8)
    RETURNING id INTO v_gen8_mother;

    INSERT INTO public.relationships (family_id, person_id, related_person_id, relationship_type, is_verified) VALUES
    (v_family_id, v_gen7_father, v_gen8_father, 'parent', true),
    (v_family_id, v_gen7_mother, v_gen8_father, 'parent', true),
    (v_family_id, v_gen8_father, v_gen8_mother, 'spouse', true);

    -- Generation 9 (1995)
    INSERT INTO public.persons (family_id, first_name, last_name, gender, birth_date, is_living, birth_place, bio, is_verified, generation_hint)
    VALUES (v_family_id, 'Lucas', 'Kensington', 'male', '1995-04-20', true, 'Seattle, USA', 'Data scientist and digital historian.', true, 9)
    RETURNING id INTO v_gen9_father;

    INSERT INTO public.persons (family_id, first_name, last_name, maiden_name, gender, birth_date, is_living, birth_place, bio, is_verified, generation_hint)
    VALUES (v_family_id, 'Elena', 'Kensington', 'Moreau', 'female', '1997-07-11', true, 'Lyon, France', 'Cellist and sound archivist.', true, 9)
    RETURNING id INTO v_gen9_mother;

    INSERT INTO public.relationships (family_id, person_id, related_person_id, relationship_type, is_verified) VALUES
    (v_family_id, v_gen8_father, v_gen9_father, 'parent', true),
    (v_family_id, v_gen8_mother, v_gen9_father, 'parent', true),
    (v_family_id, v_gen9_father, v_gen9_mother, 'spouse', true);

    -- Generation 10 (2024)
    INSERT INTO public.persons (family_id, first_name, last_name, gender, birth_date, is_living, birth_place, bio, is_verified, generation_hint)
    VALUES (v_family_id, 'Maya', 'Kensington', 'female', '2024-02-14', true, 'Seattle, USA', 'Tenth-generation heritage child of the Kensington lineage.', true, 10)
    RETURNING id INTO v_gen10_child;

    INSERT INTO public.relationships (family_id, person_id, related_person_id, relationship_type, is_verified) VALUES
    (v_family_id, v_gen9_father, v_gen10_child, 'parent', true),
    (v_family_id, v_gen9_mother, v_gen10_child, 'parent', true);

    -- Life events
    INSERT INTO public.life_events (family_id, event_type, title, description, event_date, location) VALUES
    (v_family_id, 'migration', 'Transatlantic Voyage of the Kensington Clan', 'Callum and Elspeth journeyed aboard the barque Hector to North America.', '1820-05-15', 'Atlantic Crossing'),
    (v_family_id, 'achievement', 'Founding of the Boston Engineering Atelier', 'Robert established the structural workshop that contributed to early subway tunnels.', '1875-09-01', 'Boston, Massachusetts'),
    (v_family_id, 'marriage', 'Julian & Helena Nuptials', 'Celebrated in the historic gardens overlooking Madrid.', '1958-06-20', 'Madrid, Spain');

    RAISE NOTICE '10-generation synthetic heritage lineage successfully seeded!';
END $$;
