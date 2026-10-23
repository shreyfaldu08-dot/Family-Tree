enum RelationshipType {
  parent,
  child,
  spouse,
  sibling;

  static RelationshipType fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'parent':
        return RelationshipType.parent;
      case 'child':
        return RelationshipType.child;
      case 'spouse':
        return RelationshipType.spouse;
      case 'sibling':
        return RelationshipType.sibling;
      default:
        return RelationshipType.parent;
    }
  }

  String get dbValue => name;

  String get label {
    switch (this) {
      case RelationshipType.parent:
        return 'Parent';
      case RelationshipType.child:
        return 'Child';
      case RelationshipType.spouse:
        return 'Spouse / Partner';
      case RelationshipType.sibling:
        return 'Sibling';
    }
  }
}

enum LineageType {
  biological,
  adopted,
  step,
  foster;

  static LineageType fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'adopted':
        return LineageType.adopted;
      case 'step':
        return LineageType.step;
      case 'foster':
        return LineageType.foster;
      case 'biological':
      default:
        return LineageType.biological;
    }
  }

  String get dbValue => name;

  String get label {
    switch (this) {
      case LineageType.biological:
        return 'Biological';
      case LineageType.adopted:
        return 'Adopted';
      case LineageType.step:
        return 'Step';
      case LineageType.foster:
        return 'Foster';
    }
  }
}

class Relationship {
  final String id;
  final String familyId;
  final String personId;
  final String relatedPersonId;
  final RelationshipType type;
  final LineageType lineage;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? notes;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Relationship({
    required this.id,
    required this.familyId,
    required this.personId,
    required this.relatedPersonId,
    required this.type,
    this.lineage = LineageType.biological,
    this.startDate,
    this.endDate,
    this.notes,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Relationship.fromJson(Map<String, dynamic> json) {
    return Relationship(
      id: json['id'] as String,
      familyId: json['family_id'] as String,
      personId: json['person_id'] as String,
      relatedPersonId: json['related_person_id'] as String,
      type: RelationshipType.fromString(json['relationship_type'] as String?),
      lineage: LineageType.fromString(json['lineage'] as String?),
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'] as String)
          : null,
      notes: json['notes'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
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
      'person_id': personId,
      'related_person_id': relatedPersonId,
      'relationship_type': type.dbValue,
      'lineage': lineage.dbValue,
      'start_date': startDate?.toIso8601String().split('T').first,
      'end_date': endDate?.toIso8601String().split('T').first,
      'notes': notes,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
