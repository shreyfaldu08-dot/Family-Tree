class Invitation {
  final String id;
  final String familyId;
  final String codeHash;
  final String? recipientEmail;
  final String createdBy;
  final DateTime expiresAt;
  final bool isRevoked;
  final String? redeemedBy;
  final DateTime? redeemedAt;
  final DateTime createdAt;

  const Invitation({
    required this.id,
    required this.familyId,
    required this.codeHash,
    this.recipientEmail,
    required this.createdBy,
    required this.expiresAt,
    required this.isRevoked,
    this.redeemedBy,
    this.redeemedAt,
    required this.createdAt,
  });

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id'] as String,
      familyId: json['family_id'] as String,
      codeHash: json['code_hash'] as String,
      recipientEmail: json['recipient_email'] as String?,
      createdBy: json['created_by'] as String? ?? '',
      expiresAt: DateTime.parse(json['expires_at'] as String),
      isRevoked: json['is_revoked'] as bool? ?? false,
      redeemedBy: json['redeemed_by'] as String?,
      redeemedAt: json['redeemed_at'] != null
          ? DateTime.parse(json['redeemed_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isRedeemed => redeemedAt != null;
  bool get isValid => !isRevoked && !isExpired && !isRedeemed;
}
