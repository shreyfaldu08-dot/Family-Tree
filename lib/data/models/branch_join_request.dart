class BranchJoinRequest {
  final String id;
  final String treeId;
  final String applicantName;
  final String applicantEmail;
  final String applicantGender;
  final DateTime? applicantBirthDate;
  final String? applicantHometown;
  
  // 4 Compulsory Ancestral Inputs
  final String fatherName;
  final bool fatherLiving;
  final String motherName;
  final String motherMaidenName;
  final String grandfatherName;
  final bool grandfatherLiving;
  final String grandmotherName;
  final String grandmotherMaidenName;

  // Matched Ancestor Node IDs in the active tree
  final String? matchedGrandfatherId;
  final String? matchedGrandfatherName;
  final String? matchedFatherId;
  final String? matchedFatherName;

  final String status; // 'pending' | 'verified' | 'rejected'
  final DateTime submittedAt;
  final DateTime? verifiedAt;

  const BranchJoinRequest({
    required this.id,
    required this.treeId,
    required this.applicantName,
    required this.applicantEmail,
    this.applicantGender = 'male',
    this.applicantBirthDate,
    this.applicantHometown,
    required this.fatherName,
    this.fatherLiving = false,
    required this.motherName,
    this.motherMaidenName = '',
    required this.grandfatherName,
    this.grandfatherLiving = false,
    required this.grandmotherName,
    this.grandmotherMaidenName = '',
    this.matchedGrandfatherId,
    this.matchedGrandfatherName,
    this.matchedFatherId,
    this.matchedFatherName,
    this.status = 'pending',
    required this.submittedAt,
    this.verifiedAt,
  });

  bool get isPending => status == 'pending';
  bool get isVerified => status == 'verified';

  BranchJoinRequest copyWith({
    String? status,
    DateTime? verifiedAt,
    String? matchedGrandfatherId,
    String? matchedGrandfatherName,
    String? matchedFatherId,
    String? matchedFatherName,
  }) {
    return BranchJoinRequest(
      id: id,
      treeId: treeId,
      applicantName: applicantName,
      applicantEmail: applicantEmail,
      applicantGender: applicantGender,
      applicantBirthDate: applicantBirthDate,
      applicantHometown: applicantHometown,
      fatherName: fatherName,
      fatherLiving: fatherLiving,
      motherName: motherName,
      motherMaidenName: motherMaidenName,
      grandfatherName: grandfatherName,
      grandfatherLiving: grandfatherLiving,
      grandmotherName: grandmotherName,
      grandmotherMaidenName: grandmotherMaidenName,
      matchedGrandfatherId: matchedGrandfatherId ?? this.matchedGrandfatherId,
      matchedGrandfatherName: matchedGrandfatherName ?? this.matchedGrandfatherName,
      matchedFatherId: matchedFatherId ?? this.matchedFatherId,
      matchedFatherName: matchedFatherName ?? this.matchedFatherName,
      status: status ?? this.status,
      submittedAt: submittedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }
}
