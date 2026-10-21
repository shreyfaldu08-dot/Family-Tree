enum MediaType {
  photo,
  video,
  audio,
  document;

  static MediaType fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'photo':
        return MediaType.photo;
      case 'video':
        return MediaType.video;
      case 'audio':
        return MediaType.audio;
      case 'document':
        return MediaType.document;
      default:
        return MediaType.photo;
    }
  }

  String get dbValue => name;
}

class MediaAsset {
  final String id;
  final String familyId;
  final String storagePath;
  final String storageBucket;
  final MediaType mediaType;
  final String title;
  final String? description;
  final DateTime? capturedDate;
  final bool capturedDateApprox;
  final String? mimeType;
  final int? fileSizeBytes;
  final String uploaderId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? signedUrl;

  const MediaAsset({
    required this.id,
    required this.familyId,
    required this.storagePath,
    this.storageBucket = 'family-legacy-private',
    required this.mediaType,
    required this.title,
    this.description,
    this.capturedDate,
    this.capturedDateApprox = false,
    this.mimeType,
    this.fileSizeBytes,
    required this.uploaderId,
    required this.createdAt,
    required this.updatedAt,
    this.signedUrl,
  });

  factory MediaAsset.fromJson(Map<String, dynamic> json, {String? signedUrl}) {
    return MediaAsset(
      id: json['id'] as String,
      familyId: json['family_id'] as String,
      storagePath: json['storage_path'] as String? ?? '',
      storageBucket: json['storage_bucket'] as String? ?? 'family-legacy-private',
      mediaType: MediaType.fromString(json['media_type'] as String?),
      title: json['title'] as String? ?? 'Archival Media',
      description: json['description'] as String?,
      capturedDate: json['captured_date'] != null
          ? DateTime.tryParse(json['captured_date'] as String)
          : null,
      capturedDateApprox: json['captured_date_approx'] as bool? ?? false,
      mimeType: json['mime_type'] as String?,
      fileSizeBytes: json['file_size_bytes'] as int?,
      uploaderId: json['uploader_id'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      signedUrl: signedUrl ?? json['signed_url'] as String?,
    );
  }

  MediaAsset copyWith({String? signedUrl}) {
    return MediaAsset(
      id: id,
      familyId: familyId,
      storagePath: storagePath,
      storageBucket: storageBucket,
      mediaType: mediaType,
      title: title,
      description: description,
      capturedDate: capturedDate,
      capturedDateApprox: capturedDateApprox,
      mimeType: mimeType,
      fileSizeBytes: fileSizeBytes,
      uploaderId: uploaderId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      signedUrl: signedUrl ?? this.signedUrl,
    );
  }
}
