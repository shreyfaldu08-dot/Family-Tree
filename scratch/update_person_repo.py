file_path = 'lib/data/repositories/person_repository.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

target = """    final gen9BrotherOliver = Person("""
replacement = """    final gen7GreatUncleWilliam = Person(
      id: 'p_gen7_william',
      familyId: famId,
      firstName: 'William',
      lastName: 'Kensington',
      gender: Gender.male,
      birthDate: DateTime(1932, 5, 14),
      deathDate: DateTime(2018, 9, 27),
      isLiving: false,
      birthPlace: 'London, UK',
      deathPlace: 'Edinburgh, Scotland',
      bio: "Grandfather Julian's younger brother. Master founder of the Edinburgh Architectural Foundry.",
      portraitUrl: 'assets/images/vintage_elder_father.jpg',
      isVerified: true,
      generationHint: 7,
      createdAt: now,
      updatedAt: now,
    );

    final gen8UncleRichard = Person(
      id: 'p_gen8_richard',
      familyId: famId,
      firstName: 'Richard',
      lastName: 'Kensington',
      gender: Gender.male,
      birthDate: DateTime(1964, 11, 20),
      isLiving: true,
      birthPlace: 'Edinburgh, Scotland',
      bio: "William's son and keeper of the Edinburgh branch records. Senior conservation architect.",
      portraitUrl: 'assets/images/modern_father.jpg',
      isVerified: true,
      generationHint: 8,
      createdAt: now,
      updatedAt: now,
    );

    final gen9BrotherOliver = Person("""

if target in content and 'p_gen7_william' not in content:
    content = content.replace(target, replacement)
    content = content.replace(
        "gen7Father, gen7Mother,",
        "gen7Father, gen7Mother,\n      gen7GreatUncleWilliam,\n      gen8UncleRichard,"
    )
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Updated person_repository.dart successfully!")
else:
    print("person_repository.dart already updated or target not found.")

