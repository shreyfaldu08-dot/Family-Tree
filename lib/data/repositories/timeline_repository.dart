import '../models/life_event.dart';
import '../models/membership.dart';
import '../services/supabase_service.dart';
import '../../core/security/security_guards.dart';

class TimelineRepository {
  final SupabaseService _supabase;
  final List<LifeEvent> _memoryStore = [];

  TimelineRepository({required SupabaseService supabase}) : _supabase = supabase {
    _initSampleEvents();
  }

  Future<List<LifeEvent>> getTimelineEvents(
    String familyId,
    FamilyMembership? membership, {
    String? personId,
  }) async {
    if (!_supabase.isInitialized) {
      var list = _memoryStore.where((e) => e.familyId == familyId).toList();
      if (personId != null) {
        list = list.where((e) => e.linkedPersonIds.contains(personId)).toList();
      }
      list.sort((a, b) {
        final aDate = a.eventDate ?? DateTime(a.eventYearApprox ?? 1700);
        final bDate = b.eventDate ?? DateTime(b.eventYearApprox ?? 1700);
        return aDate.compareTo(bDate);
      });
      return List.unmodifiable(list);
    }

    SecurityGuards.assertCanRead(membership);

    try {
      final res = await _supabase.client
          .from('life_events')
          .select('*, event_person_links(*)')
          .eq('family_id', familyId)
          .order('event_date', ascending: true);

      final events = (res as List).map((e) => LifeEvent.fromJson(e as Map<String, dynamic>)).toList();
      if (events.isEmpty && _memoryStore.isNotEmpty) {
        return List.unmodifiable(_memoryStore.where((e) => e.familyId == familyId));
      }
      return events;
    } catch (_) {
      return List.unmodifiable(_memoryStore.where((e) => e.familyId == familyId));
    }
  }

  Future<LifeEvent> createLifeEvent(
    LifeEvent event,
    FamilyMembership? membership,
  ) async {
    SecurityGuards.assertPrimaryAdmin(membership, operation: 'record family timeline events');

    if (!_supabase.isInitialized) {
      _memoryStore.add(event);
      return event;
    }

    try {
      final res = await _supabase.client
          .from('life_events')
          .insert({
            'family_id': event.familyId,
            'event_type': event.eventType.dbValue,
            'title': event.title,
            'description': event.description,
            'event_date': event.eventDate?.toIso8601String().split('T').first,
            'event_date_approx': event.eventDateApprox,
            'event_year_approx': event.eventYearApprox,
            'location': event.location,
          })
          .select()
          .single();

      return LifeEvent.fromJson(res);
    } catch (_) {
      _memoryStore.add(event);
      return event;
    }
  }

  void _initSampleEvents() {
    const famId = 'fam_kensington_01';
    final now = DateTime.now();

    _memoryStore.addAll([
      LifeEvent(
        id: 'evt_01',
        familyId: famId,
        eventType: EventType.custom,
        title: 'Archibald Kensington Founds Lowland Masonry Guild',
        description: 'Guild Charter signed by Archibald under the burgh seal of Edinburgh.',
        eventDate: DateTime(1748, 8, 12),
        location: 'Edinburgh, Scotland',
        linkedPersonIds: ['p_gen1_archibald'],
        createdAt: now,
      ),
      LifeEvent(
        id: 'evt_02',
        familyId: famId,
        eventType: EventType.migration,
        title: 'Atlantic Crossing on the Barque Hector',
        description: 'Callum and Elspeth journeyed six weeks across the stormy North Atlantic to establish home in Montreal.',
        eventDate: DateTime(1820, 5, 15),
        location: 'Atlantic Crossing to Montreal',
        linkedPersonIds: ['p_gen3_callum', 'p_gen3_elspeth'],
        createdAt: now,
      ),
      LifeEvent(
        id: 'evt_03',
        familyId: famId,
        eventType: EventType.achievement,
        title: 'Completion of the Boston Rail Viaducts',
        description: 'Robert Kensington oversaw the granite arches that connected Boston south lines.',
        eventDate: DateTime(1875, 9, 1),
        location: 'Boston, Massachusetts',
        linkedPersonIds: ['p_gen4_robert'],
        createdAt: now,
      ),
      LifeEvent(
        id: 'evt_04',
        familyId: famId,
        eventType: EventType.marriage,
        title: 'Marriage of Julian Kensington & Helena Alvarez',
        description: 'Historic ceremony celebrated in Madrid prior to their move to the Pacific coast.',
        eventDate: DateTime(1958, 6, 20),
        location: 'Madrid, Spain',
        linkedPersonIds: ['p_gen7_julian', 'p_gen7_helena'],
        createdAt: now,
      ),
      LifeEvent(
        id: 'evt_05',
        familyId: famId,
        eventType: EventType.birth,
        title: 'Birth of Maya Kensington (Generation X)',
        description: 'The tenth unbroken generation of the Kensington lineage born in the Pacific Northwest.',
        eventDate: DateTime(2024, 2, 14),
        location: 'Seattle, Washington',
        linkedPersonIds: ['p_gen10_maya', 'p_gen9_lucas', 'p_gen9_elena'],
        createdAt: now,
      ),
    ]);
  }
}
