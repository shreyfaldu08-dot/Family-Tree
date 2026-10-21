enum EventType {
  birth,
  marriage,
  death,
  migration,
  education,
  achievement,
  residence,
  custom;

  static EventType fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'birth':
        return EventType.birth;
      case 'marriage':
        return EventType.marriage;
      case 'death':
        return EventType.death;
      case 'migration':
        return EventType.migration;
      case 'education':
        return EventType.education;
      case 'achievement':
        return EventType.achievement;
      case 'residence':
        return EventType.residence;
      default:
        return EventType.custom;
    }
  }

  String get label {
    switch (this) {
      case EventType.birth:
        return 'Birth';
      case EventType.marriage:
        return 'Marriage / Union';
      case EventType.death:
        return 'Passing';
      case EventType.migration:
        return 'Migration / Journey';
      case EventType.education:
        return 'Education';
      case EventType.achievement:
        return 'Honour / Achievement';
      case EventType.residence:
        return 'Homestead / Residence';
      case EventType.custom:
        return 'Historical Milestone';
    }
  }

  String get dbValue => name;
}

class LifeEvent {
  final String id;
  final String familyId;
  final EventType eventType;
  final String title;
  final String? description;
  final DateTime? eventDate;
  final bool eventDateApprox;
  final int? eventYearApprox;
  final String? location;
  final List<String> linkedPersonIds;
  final DateTime createdAt;

  const LifeEvent({
    required this.id,
    required this.familyId,
    required this.eventType,
    required this.title,
    this.description,
    this.eventDate,
    this.eventDateApprox = false,
    this.eventYearApprox,
    this.location,
    this.linkedPersonIds = const [],
    required this.createdAt,
  });

  factory LifeEvent.fromJson(Map<String, dynamic> json, {List<String>? personIds}) {
    return LifeEvent(
      id: json['id'] as String,
      familyId: json['family_id'] as String,
      eventType: EventType.fromString(json['event_type'] as String?),
      title: json['title'] as String? ?? 'Historical Event',
      description: json['description'] as String?,
      eventDate: json['event_date'] != null
          ? DateTime.tryParse(json['event_date'] as String)
          : null,
      eventDateApprox: json['event_date_approx'] as bool? ?? false,
      eventYearApprox: json['event_year_approx'] as int?,
      location: json['location'] as String?,
      linkedPersonIds: personIds ??
          (json['event_person_links'] as List<dynamic>?)
              ?.map((e) => (e['person_id'] as String))
              .toList() ??
          const [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  String get formattedDate {
    if (eventDateApprox && eventYearApprox != null) {
      return 'c. $eventYearApprox';
    }
    if (eventDate != null) {
      return '${eventDate!.year}-${eventDate!.month.toString().padLeft(2, '0')}-${eventDate!.day.toString().padLeft(2, '0')}';
    }
    return 'Undated';
  }
}
