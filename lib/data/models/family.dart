class Family {
  final String id;
  final String name;
  final String? motto;
  final String? description;
  final String? originPlace;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Family({
    required this.id,
    required this.name,
    this.motto,
    this.description,
    this.originPlace,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Family.fromJson(Map<String, dynamic> json) {
    return Family(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Family Archive',
      motto: json['motto'] as String?,
      description: json['description'] as String?,
      originPlace: json['origin_place'] as String?,
      createdBy: json['created_by'] as String? ?? '',
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
      'name': name,
      'motto': motto,
      'description': description,
      'origin_place': originPlace,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
