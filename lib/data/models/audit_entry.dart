class AuditEntry {
  final String id;
  final String familyId;
  final String actorId;
  final String action;
  final String entityType;
  final String entityId;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final String? actorEmail;

  const AuditEntry({
    required this.id,
    required this.familyId,
    required this.actorId,
    required this.action,
    required this.entityType,
    required this.entityId,
    this.payload = const {},
    required this.createdAt,
    this.actorEmail,
  });

  factory AuditEntry.fromJson(Map<String, dynamic> json) {
    return AuditEntry(
      id: json['id'] as String,
      familyId: json['family_id'] as String,
      actorId: json['actor_id'] as String? ?? '',
      action: json['action'] as String? ?? 'action',
      entityType: json['entity_type'] as String? ?? '',
      entityId: json['entity_id'] as String? ?? '',
      payload: (json['payload'] as Map<String, dynamic>?) ?? const {},
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      actorEmail: json['profiles'] != null ? json['profiles']['email'] as String? : null,
    );
  }
}
