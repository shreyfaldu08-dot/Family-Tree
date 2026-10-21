import '../models/person.dart';
import '../models/membership.dart';
import '../services/supabase_service.dart';
import '../../core/security/security_guards.dart';

class PersonRepository {
  final SupabaseService _supabase;
  final List<Person> _memoryStore = [];

  PersonRepository({required SupabaseService supabase}) : _supabase = supabase {
    _initSample10Generations();
  }

  Future<List<Person>> getPersonsForFamily(String familyId, FamilyMembership? membership) async {
    SecurityGuards.assertCanRead(membership);

    if (!_supabase.isInitialized) {
      return List.unmodifiable(_memoryStore.where((p) => p.familyId == familyId));
    }

    try {
      final res = await _supabase.client
          .from('persons')
          .select()
          .eq('family_id', familyId)
          .order('birth_date', ascending: true);

      final list = (res as List).map((e) => Person.fromJson(e as Map<String, dynamic>)).toList();
      if (list.isEmpty && _memoryStore.isNotEmpty) {
        return List.unmodifiable(_memoryStore.where((p) => p.familyId == familyId));
      }
      return list;
    } catch (_) {
      return List.unmodifiable(_memoryStore.where((p) => p.familyId == familyId));
    }
  }

  Future<Person?> getPersonById(String personId, FamilyMembership? membership) async {
    SecurityGuards.assertCanRead(membership);

    if (!_supabase.isInitialized) {
      try {
        return _memoryStore.firstWhere((p) => p.id == personId);
      } catch (_) {
        return null;
      }
    }

    try {
      final res = await _supabase.client
          .from('persons')
          .select()
          .eq('id', personId)
          .maybeSingle();

      if (res != null) {
        return Person.fromJson(res);
      }
      return _memoryStore.where((p) => p.id == personId).firstOrNull;
    } catch (_) {
      return _memoryStore.where((p) => p.id == personId).firstOrNull;
    }
  }

  /// Create a person record (Primary Admin only)
  Future<Person> createPerson(Person person, FamilyMembership? membership) async {
    SecurityGuards.assertPrimaryAdmin(membership, operation: 'create person records');

    if (!_supabase.isInitialized) {
      _memoryStore.add(person);
      return person;
    }

    try {
      final res = await _supabase.client
          .from('persons')
          .insert(person.toJson())
          .select()
          .single();
      return Person.fromJson(res);
    } catch (e) {
      // In local mode fallback
      _memoryStore.add(person);
      return person;
    }
  }

  /// Update person record (Primary Admin only)
  Future<Person> updatePerson(Person person, FamilyMembership? membership) async {
    SecurityGuards.assertPrimaryAdmin(membership, operation: 'modify person records');

    if (!_supabase.isInitialized) {
      final idx = _memoryStore.indexWhere((p) => p.id == person.id);
      if (idx != -1) {
        _memoryStore[idx] = person;
      } else {
        _memoryStore.add(person);
      }
      return person;
    }

    try {
      final res = await _supabase.client
          .from('persons')
          .update(person.toJson())
          .eq('id', person.id)
          .select()
          .single();
      return Person.fromJson(res);
    } catch (e) {
      final idx = _memoryStore.indexWhere((p) => p.id == person.id);
      if (idx != -1) _memoryStore[idx] = person;
      return person;
    }
  }

  /// Delete person record (Primary Admin only)
  Future<void> deletePerson(String personId, FamilyMembership? membership) async {
    SecurityGuards.assertPrimaryAdmin(membership, operation: 'delete person records');

    if (!_supabase.isInitialized) {
      _memoryStore.removeWhere((p) => p.id == personId);
      return;
    }

    try {
      await _supabase.client.from('persons').delete().eq('id', personId);
    } catch (_) {
      _memoryStore.removeWhere((p) => p.id == personId);
    }
  }

  /// Duplicate Detection: Searches for potential duplicates with matching names and close birth years
  Future<List<Person>> findPotentialDuplicates({
    required String familyId,
    required String firstName,
    required String lastName,
    int? birthYear,
    String? excludePersonId,
    FamilyMembership? membership,
  }) async {
    final allPersons = await getPersonsForFamily(familyId, membership);

    final cleanFirst = firstName.trim().toLowerCase();
    final cleanLast = lastName.trim().toLowerCase();

    return allPersons.where((p) {
      if (excludePersonId != null && p.id == excludePersonId) return false;

      final sameLast = p.lastName.toLowerCase() == cleanLast;
      final sameFirst = p.firstName.toLowerCase() == cleanFirst ||
          (p.preferredName != null && p.preferredName!.toLowerCase() == cleanFirst);

      if (!sameFirst || !sameLast) return false;

      if (birthYear != null) {
        final pYear = p.birthDate?.year ?? p.birthYearApprox;
        if (pYear != null && (pYear - birthYear).abs() > 3) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Initializes the authentic 10-generation Kensington Living Heritage lineage
  void _initSample10Generations() {
    const famId = 'fam_kensington_01';
    final now = DateTime.now();

    final gen1Father = Person(
      id: 'p_gen1_archibald',
      familyId: famId,
      firstName: 'Archibald',
      lastName: 'Kensington',
      gender: Gender.male,
      birthDate: DateTime(1720, 4, 12),
      deathDate: DateTime(1792, 11, 4),
      isLiving: false,
      birthPlace: 'Edinburgh, Scotland',
      deathPlace: 'Stirling, Scotland',
      bio: 'Master stone mason and founder of the family guild in Edinburgh.',
      lifeStory: 'Archibald began as an apprentice in the Royal Mile masonry guild. He oversaw the construction of four major stone bridges across the Scottish Lowlands.',
      isVerified: true,
      generationHint: 1,
      createdAt: now,
      updatedAt: now,
    );

    final gen1Mother = Person(
      id: 'p_gen1_margaret',
      familyId: famId,
      firstName: 'Margaret',
      lastName: 'Kensington',
      maidenName: 'MacLeod',
      gender: Gender.female,
      birthDate: DateTime(1724, 8, 19),
      deathDate: DateTime(1801, 2, 14),
      isLiving: false,
      birthPlace: 'Isle of Skye, Scotland',
      deathPlace: 'Edinburgh, Scotland',
      bio: 'Highland herbalist and keeper of clan oral histories.',
      isVerified: true,
      generationHint: 1,
      createdAt: now,
      updatedAt: now,
    );

    final gen2Father = Person(
      id: 'p_gen2_hamish',
      familyId: famId,
      firstName: 'Hamish',
      lastName: 'Kensington',
      gender: Gender.male,
      birthDate: DateTime(1755, 6, 10),
      deathDate: DateTime(1828, 9, 21),
      isLiving: false,
      birthPlace: 'Edinburgh, Scotland',
      deathPlace: 'Aberdeen, Scotland',
      bio: 'Naval architect and merchant mariner during the North Sea trade boom.',
      isVerified: true,
      generationHint: 2,
      createdAt: now,
      updatedAt: now,
    );

    final gen2Mother = Person(
      id: 'p_gen2_isla',
      familyId: famId,
      firstName: 'Isla',
      lastName: 'Kensington',
      maidenName: 'Sinclair',
      gender: Gender.female,
      birthDate: DateTime(1760, 3, 15),
      deathDate: DateTime(1835, 12, 1),
      isLiving: false,
      birthPlace: 'Orkney, Scotland',
      deathPlace: 'Aberdeen, Scotland',
      bio: 'Botanical illustrator and weaver.',
      isVerified: true,
      generationHint: 2,
      createdAt: now,
      updatedAt: now,
    );

    final gen3Father = Person(
      id: 'p_gen3_callum',
      familyId: famId,
      firstName: 'Callum',
      lastName: 'Kensington',
      gender: Gender.male,
      birthDate: DateTime(1790, 1, 22),
      deathDate: DateTime(1863, 4, 18),
      isLiving: false,
      birthPlace: 'Aberdeen, Scotland',
      deathPlace: 'Montreal, Canada',
      bio: 'Pioneer surveyor who charted early Canadian waterway transit lines.',
      isVerified: true,
      generationHint: 3,
      createdAt: now,
      updatedAt: now,
    );

    final gen3Mother = Person(
      id: 'p_gen3_elspeth',
      familyId: famId,
      firstName: 'Elspeth',
      lastName: 'Kensington',
      maidenName: 'Campbell',
      gender: Gender.female,
      birthDate: DateTime(1794, 9, 30),
      deathDate: DateTime(1870, 7, 11),
      isLiving: false,
      birthPlace: 'Inverness, Scotland',
      deathPlace: 'Montreal, Canada',
      bio: 'Educator and founder of the Lower Canada literacy league.',
      isVerified: true,
      generationHint: 3,
      createdAt: now,
      updatedAt: now,
    );

    final gen4Father = Person(
      id: 'p_gen4_robert',
      familyId: famId,
      firstName: 'Robert',
      lastName: 'Kensington',
      gender: Gender.male,
      birthDate: DateTime(1825, 11, 14),
      deathDate: DateTime(1902, 8, 5),
      isLiving: false,
      birthPlace: 'Montreal, Canada',
      deathPlace: 'Boston, USA',
      bio: 'Civil engineer on the Eastern seaboard transcontinental lines.',
      isVerified: true,
      generationHint: 4,
      createdAt: now,
      updatedAt: now,
    );

    final gen4Mother = Person(
      id: 'p_gen4_beatrice',
      familyId: famId,
      firstName: 'Beatrice',
      lastName: 'Kensington',
      maidenName: 'Tremblay',
      gender: Gender.female,
      birthDate: DateTime(1831, 5, 18),
      deathDate: DateTime(1910, 1, 20),
      isLiving: false,
      birthPlace: 'Quebec City, Canada',
      deathPlace: 'Boston, USA',
      bio: 'Pianist and patron of chamber orchestra societies.',
      isVerified: true,
      generationHint: 4,
      createdAt: now,
      updatedAt: now,
    );

    final gen5Father = Person(
      id: 'p_gen5_charles',
      familyId: famId,
      firstName: 'Charles',
      lastName: 'Kensington',
      gender: Gender.male,
      birthDate: DateTime(1860, 7, 4),
      deathDate: DateTime(1934, 10, 12),
      isLiving: false,
      birthPlace: 'Boston, USA',
      deathPlace: 'New York, USA',
      bio: 'Professor of Natural Philosophy and pioneer in telegraph acoustics.',
      isVerified: true,
      generationHint: 5,
      createdAt: now,
      updatedAt: now,
    );

    final gen5Mother = Person(
      id: 'p_gen5_clara',
      familyId: famId,
      firstName: 'Clara',
      lastName: 'Kensington',
      maidenName: 'Fairchild',
      gender: Gender.female,
      birthDate: DateTime(1865, 2, 28),
      deathDate: DateTime(1945, 9, 3),
      isLiving: false,
      birthPlace: 'Providence, USA',
      deathPlace: 'New York, USA',
      bio: 'Astronomer and stellar photographic classifier.',
      isVerified: true,
      generationHint: 5,
      createdAt: now,
      updatedAt: now,
    );

    final gen6Father = Person(
      id: 'p_gen6_arthur',
      familyId: famId,
      firstName: 'Arthur',
      lastName: 'Kensington',
      gender: Gender.male,
      birthDate: DateTime(1895, 3, 12),
      deathDate: DateTime(1971, 6, 25),
      isLiving: false,
      birthPlace: 'New York, USA',
      deathPlace: 'London, UK',
      bio: 'Field surgeon in the Great War and later chief of thoracic medicine.',
      isVerified: true,
      generationHint: 6,
      createdAt: now,
      updatedAt: now,
    );

    final gen6Mother = Person(
      id: 'p_gen6_evelyn',
      familyId: famId,
      firstName: 'Evelyn',
      lastName: 'Kensington',
      maidenName: 'Vane',
      gender: Gender.female,
      birthDate: DateTime(1900, 11, 9),
      deathDate: DateTime(1988, 3, 19),
      isLiving: false,
      birthPlace: 'London, UK',
      deathPlace: 'London, UK',
      bio: 'Public health reformer and author of nursing manuals.',
      isVerified: true,
      generationHint: 6,
      createdAt: now,
      updatedAt: now,
    );

    final gen7Father = Person(
      id: 'p_gen7_julian',
      familyId: famId,
      firstName: 'Julian',
      lastName: 'Kensington',
      gender: Gender.male,
      birthDate: DateTime(1930, 10, 18),
      deathDate: DateTime(2012, 1, 8),
      isLiving: false,
      birthPlace: 'London, UK',
      deathPlace: 'San Francisco, USA',
      bio: 'Aerospace structural analyst and alpine sailplane pilot.',
      isVerified: true,
      generationHint: 7,
      createdAt: now,
      updatedAt: now,
    );

    final gen7Mother = Person(
      id: 'p_gen7_helena',
      familyId: famId,
      firstName: 'Helena',
      lastName: 'Kensington',
      maidenName: 'Alvarez',
      gender: Gender.female,
      birthDate: DateTime(1935, 8, 22),
      deathDate: DateTime(2021, 4, 14),
      isLiving: false,
      birthPlace: 'Madrid, Spain',
      deathPlace: 'San Francisco, USA',
      bio: 'Architectural historian specialized in colonial restoration.',
      isVerified: true,
      generationHint: 7,
      createdAt: now,
      updatedAt: now,
    );

    final gen8Father = Person(
      id: 'p_gen8_david',
      familyId: famId,
      firstName: 'David',
      lastName: 'Kensington',
      gender: Gender.male,
      birthDate: DateTime(1962, 9, 5),
      isLiving: true,
      birthPlace: 'San Francisco, USA',
      bio: 'Software engineer and chief archivist of the Kensington collections.',
      lifeStory: 'David spent three decades collecting oral testimonies and scanning thousands of historical documents to establish this living family heritage record.',
      isVerified: true,
      generationHint: 8,
      createdAt: now,
      updatedAt: now,
    );

    final gen8Mother = Person(
      id: 'p_gen8_sophia',
      familyId: famId,
      firstName: 'Sophia',
      lastName: 'Kensington',
      maidenName: 'Sterling',
      gender: Gender.female,
      birthDate: DateTime(1966, 12, 14),
      isLiving: true,
      birthPlace: 'Seattle, USA',
      bio: 'Environmental educator and botanical conservationist.',
      isVerified: true,
      generationHint: 8,
      createdAt: now,
      updatedAt: now,
    );

    final gen9Father = Person(
      id: 'p_gen9_lucas',
      familyId: famId,
      firstName: 'Lucas',
      lastName: 'Kensington',
      gender: Gender.male,
      birthDate: DateTime(1995, 4, 20),
      isLiving: true,
      birthPlace: 'Seattle, USA',
      bio: 'Data scientist and digital heritage developer.',
      isVerified: true,
      generationHint: 9,
      createdAt: now,
      updatedAt: now,
    );

    final gen9Mother = Person(
      id: 'p_gen9_elena',
      familyId: famId,
      firstName: 'Elena',
      lastName: 'Kensington',
      maidenName: 'Moreau',
      gender: Gender.female,
      birthDate: DateTime(1997, 7, 11),
      isLiving: true,
      birthPlace: 'Lyon, France',
      bio: 'Concert cellist and acoustic music researcher.',
      isVerified: true,
      generationHint: 9,
      createdAt: now,
      updatedAt: now,
    );

    final gen10Child = Person(
      id: 'p_gen10_maya',
      familyId: famId,
      firstName: 'Maya',
      lastName: 'Kensington',
      gender: Gender.female,
      birthDate: DateTime(2024, 2, 14),
      isLiving: true,
      birthPlace: 'Seattle, USA',
      bio: 'Tenth generation child of the Kensington heritage line.',
      isVerified: true,
      generationHint: 10,
      createdAt: now,
      updatedAt: now,
    );

    _memoryStore.addAll([
      gen1Father, gen1Mother,
      gen2Father, gen2Mother,
      gen3Father, gen3Mother,
      gen4Father, gen4Mother,
      gen5Father, gen5Mother,
      gen6Father, gen6Mother,
      gen7Father, gen7Mother,
      gen8Father, gen8Mother,
      gen9Father, gen9Mother,
      gen10Child,
    ]);
  }
}
