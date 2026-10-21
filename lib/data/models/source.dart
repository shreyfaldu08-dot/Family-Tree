class HistoricalSource {
  final String id;
  final String familyId;
  final String title;
  final String citation;
  final String? repository;
  final String? url;
  final String? sourceType;
  final DateTime createdAt;

  const HistoricalSource({
    required this.id,
    required this.familyId,
    required this.title,
    required this.citation,
    this.repository,
    this.url,
    this.sourceType,
    required this.createdAt,
  });

  factory HistoricalSource.fromJson(Map<String, dynamic> json) {
    return HistoricalSource(
      id: json['id'] as String,
      familyId: json['family_id'] as String,
      title: json['title'] as String? ?? 'Historical Document',
      citation: json['citation'] as String? ?? '',
      repository: json['repository'] as String?,
      url: json['url'] as String?,
      sourceType: json['source_type'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'family_id': familyId,
      'title': title,
      'citation': citation,
      'repository': repository,
      'url': url,
      'source_type': sourceType,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
