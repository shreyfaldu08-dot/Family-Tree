enum Gender {
  male,
  female,
  other,
  unknown;

  static Gender fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      case 'other':
        return Gender.other;
      default:
        return Gender.unknown;
    }
  }

  String get dbValue => name;
}

class Person {
  final String id;
  final String familyId;
  final String? linkedUserId;
  final String firstName;
  final String lastName;
  final String? preferredName;
  final String? maidenName;
  final List<String> alternateNames;
  final Gender gender;
  final DateTime? birthDate;
  final bool birthDateApprox;
  final int? birthYearApprox;
  final int? birthYear;
  final int? birthMonth;
  final int? birthDay;
  final String? birthPlace;
  final DateTime? deathDate;
  final bool deathDateApprox;
  final int? deathYearApprox;
  final int? deathYear;
  final int? deathMonth;
  final int? deathDay;
  final String? deathPlace;
  final bool isLiving;
  final String? bio;
  final String? lifeStory;
  final String? portraitUrl;
  final bool isVerified;
  final int? generationHint;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Person({
    required this.id,
    required this.familyId,
    this.linkedUserId,
    required this.firstName,
    required this.lastName,
    this.preferredName,
    this.maidenName,
    this.alternateNames = const [],
    this.gender = Gender.unknown,
    this.birthDate,
    this.birthDateApprox = false,
    this.birthYearApprox,
    this.birthYear,
    this.birthMonth,
    this.birthDay,
    this.birthPlace,
    this.deathDate,
    this.deathDateApprox = false,
    this.deathYearApprox,
    this.deathYear,
    this.deathMonth,
    this.deathDay,
    this.deathPlace,
    this.isLiving = true,
    this.bio,
    this.lifeStory,
    this.portraitUrl,
    this.isVerified = false,
    this.generationHint,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as String,
      familyId: json['family_id'] as String,
      linkedUserId: json['linked_user_id'] as String?,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      preferredName: json['preferred_name'] as String?,
      maidenName: json['maiden_name'] as String?,
      alternateNames: (json['alternate_names'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      gender: Gender.fromString(json['gender'] as String?),
      birthDate: json['birth_date'] != null
          ? DateTime.tryParse(json['birth_date'] as String)
          : null,
      birthDateApprox: json['birth_date_approx'] as bool? ?? false,
      birthYearApprox: json['birth_year_approx'] as int?,
      birthYear: json['birth_year'] as int?,
      birthMonth: json['birth_month'] as int?,
      birthDay: json['birth_day'] as int?,
      birthPlace: json['birth_place'] as String?,
      deathDate: json['death_date'] != null
          ? DateTime.tryParse(json['death_date'] as String)
          : null,
      deathDateApprox: json['death_date_approx'] as bool? ?? false,
      deathYearApprox: json['death_year_approx'] as int?,
      deathYear: json['death_year'] as int?,
      deathMonth: json['death_month'] as int?,
      deathDay: json['death_day'] as int?,
      deathPlace: json['death_place'] as String?,
      isLiving: json['is_living'] as bool? ?? true,
      bio: json['bio'] as String?,
      lifeStory: json['life_story'] as String?,
      portraitUrl: json['portrait_url'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      generationHint: json['generation_hint'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'family_id': familyId,
      'linked_user_id': linkedUserId,
      'first_name': firstName,
      'last_name': lastName,
      'preferred_name': preferredName,
      'maiden_name': maidenName,
      'alternate_names': alternateNames,
      'gender': gender.dbValue,
      'birth_date': birthDate?.toIso8601String().split('T').first,
      'birth_date_approx': birthDateApprox,
      'birth_year_approx': birthYearApprox,
      'birth_year': birthYear,
      'birth_month': birthMonth,
      'birth_day': birthDay,
      'birth_place': birthPlace,
      'death_date': deathDate?.toIso8601String().split('T').first,
      'death_date_approx': deathDateApprox,
      'death_year_approx': deathYearApprox,
      'death_year': deathYear,
      'death_month': deathMonth,
      'death_day': deathDay,
      'death_place': deathPlace,
      'is_living': isLiving,
      'bio': bio,
      'life_story': lifeStory,
      'portrait_url': portraitUrl,
      'is_verified': isVerified,
      'generation_hint': generationHint,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get displayName {
    if (preferredName != null && preferredName!.trim().isNotEmpty) {
      return '$preferredName $lastName';
    }
    return '$firstName $lastName';
  }

  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last';
  }

  String get lifeDateSpan {
    final birth = birthDateApprox && birthYearApprox != null
        ? 'c. $birthYearApprox'
        : birthYear != null
            ? '$birthYear'
            : birthDate != null
                ? '${birthDate!.year}'
                : 'Unknown';

    if (isLiving) {
      return '$birth — Present';
    }

    final death = deathDateApprox && deathYearApprox != null
        ? 'c. $deathYearApprox'
        : deathYear != null
            ? '$deathYear'
            : deathDate != null
                ? '${deathDate!.year}'
                : 'Unknown';

    return '$birth — $death';
  }

  bool matchesQuery(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    if (firstName.toLowerCase().contains(q)) return true;
    if (lastName.toLowerCase().contains(q)) return true;
    if (preferredName != null && preferredName!.toLowerCase().contains(q)) return true;
    if (maidenName != null && maidenName!.toLowerCase().contains(q)) return true;
    for (final alt in alternateNames) {
      if (alt.toLowerCase().contains(q)) return true;
    }
    if (birthPlace != null && birthPlace!.toLowerCase().contains(q)) return true;
    return false;
  }

  int get generation => generationHint ?? 1;
  String get lifespanDisplay => lifeDateSpan;

  String get effectivePortraitAsset {
    if (portraitUrl != null && portraitUrl!.trim().isNotEmpty) {
      return portraitUrl!.trim();
    }
    final gen = generationHint ?? 1;
    if (gender == Gender.female) {
      if (gen >= 10) {
        return 'assets/images/child_portrait.jpg';
      } else if (gen >= 8) {
        return 'assets/images/user_sara_portrait.jpg';
      } else if (gen >= 4) {
        return 'assets/images/vintage_lady_portrait.jpg';
      } else {
        return 'assets/images/matriarch_portrait.jpg';
      }
    } else {
      if (gen >= 9) {
        return 'assets/images/modern_young_man.jpg';
      } else if (gen >= 7) {
        return 'assets/images/modern_father.jpg';
      } else if (gen >= 4) {
        return 'assets/images/midcentury_father.jpg';
      } else if (gen >= 2) {
        return 'assets/images/vintage_elder_father.jpg';
      } else {
        return 'assets/images/archibald_portrait.jpg';
      }
    }
  }
}
