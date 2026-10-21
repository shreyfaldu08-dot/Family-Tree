enum MemberRole {
  primaryAdmin,
  viewer;

  static MemberRole fromString(String? val) {
    if (val == 'primary_admin') return MemberRole.primaryAdmin;
    return MemberRole.viewer;
  }

  String get dbValue => this == MemberRole.primaryAdmin ? 'primary_admin' : 'viewer';
  bool get isPrimaryAdmin => this == MemberRole.primaryAdmin;
}

enum MemberStatus {
  active,
  revoked;

  static MemberStatus fromString(String? val) {
    if (val == 'revoked') return MemberStatus.revoked;
    return MemberStatus.active;
  }

  String get dbValue => this == MemberStatus.revoked ? 'revoked' : 'active';
  bool get isActive => this == MemberStatus.active;
}

class FamilyMembership {
  final String id;
  final String familyId;
  final String userId;
  final MemberRole role;
  final MemberStatus status;
  final DateTime joinedAt;
  final DateTime updatedAt;
  final String? userEmail;
  final String? userDisplayName;

  const FamilyMembership({
    required this.id,
    required this.familyId,
    required this.userId,
    required this.role,
    required this.status,
    required this.joinedAt,
    required this.updatedAt,
    this.userEmail,
    this.userDisplayName,
  });

  factory FamilyMembership.fromJson(Map<String, dynamic> json) {
    return FamilyMembership(
      id: json['id'] as String,
      familyId: json['family_id'] as String,
      userId: json['user_id'] as String,
      role: MemberRole.fromString(json['role'] as String?),
      status: MemberStatus.fromString(json['status'] as String?),
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      userEmail: json['profiles'] != null ? json['profiles']['email'] as String? : null,
      userDisplayName:
          json['profiles'] != null ? json['profiles']['display_name'] as String? : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'family_id': familyId,
      'user_id': userId,
      'role': role.dbValue,
      'status': status.dbValue,
      'joined_at': joinedAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isApprovedAndActive => status.isActive;
  bool get canWriteFamilyData => role.isPrimaryAdmin && isApprovedAndActive;
}

class MembershipRequest {
  final String id;
  final String familyId;
  final String userId;
  final String? invitationId;
  final String? note;
  final String status; // 'pending', 'approved', 'rejected'
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime createdAt;
  final String? requesterEmail;
  final String? requesterDisplayName;

  const MembershipRequest({
    required this.id,
    required this.familyId,
    required this.userId,
    this.invitationId,
    this.note,
    required this.status,
    this.reviewedBy,
    this.reviewedAt,
    required this.createdAt,
    this.requesterEmail,
    this.requesterDisplayName,
  });

  factory MembershipRequest.fromJson(Map<String, dynamic> json) {
    return MembershipRequest(
      id: json['id'] as String,
      familyId: json['family_id'] as String,
      userId: json['user_id'] as String,
      invitationId: json['invitation_id'] as String?,
      note: json['note'] as String?,
      status: json['status'] as String? ?? 'pending',
      reviewedBy: json['reviewed_by'] as String?,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      requesterEmail:
          json['profiles'] != null ? json['profiles']['email'] as String? : null,
      requesterDisplayName:
          json['profiles'] != null ? json['profiles']['display_name'] as String? : null,
    );
  }
}
