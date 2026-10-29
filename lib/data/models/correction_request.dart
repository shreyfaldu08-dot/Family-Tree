class CorrectionRequest {
  final String id;
  final String userId;
  final String userName;
  final String personId;
  final String personName;
  final String message;
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime createdAt;

  const CorrectionRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.personId,
    required this.personName,
    required this.message,
    this.status = 'pending',
    required this.createdAt,
  });

  String get suggestedByName => userName;
  String get note => message;

  CorrectionRequest copyWith({
    String? status,
  }) {
    return CorrectionRequest(
      id: id,
      userId: userId,
      userName: userName,
      personId: personId,
      personName: personName,
      message: message,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
