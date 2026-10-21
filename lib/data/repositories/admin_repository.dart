import 'dart:convert';
import '../models/audit_entry.dart';
import '../models/membership.dart';
import '../models/person.dart';
import '../models/relationship.dart';
import '../services/supabase_service.dart';
import 'person_repository.dart';
import 'relationship_repository.dart';
import 'media_repository.dart';
import 'timeline_repository.dart';
import '../../core/security/security_guards.dart';

class AdminRepository {
  final SupabaseService _supabase;
  final PersonRepository _personRepo;
  final RelationshipRepository _relationshipRepo;
  final MediaRepository _mediaRepo;
  final TimelineRepository _timelineRepo;

  final List<AuditEntry> _mockAuditLogs = [];

  AdminRepository({
    required SupabaseService supabase,
    required PersonRepository personRepo,
    required RelationshipRepository relationshipRepo,
    required MediaRepository mediaRepo,
    required TimelineRepository timelineRepo,
  })  : _supabase = supabase,
        _personRepo = personRepo,
        _relationshipRepo = relationshipRepo,
        _mediaRepo = mediaRepo,
        _timelineRepo = timelineRepo {
    _initSampleAuditLogs();
  }

  Future<List<AuditEntry>> getAuditLogs(
    String familyId,
    FamilyMembership? membership,
  ) async {
    SecurityGuards.assertPrimaryAdmin(membership, operation: 'review administrative audit history');

    if (!_supabase.isInitialized) {
      return List.unmodifiable(_mockAuditLogs.where((l) => l.familyId == familyId));
    }

    try {
      final res = await _supabase.client
          .from('audit_logs')
          .select('*, profiles(email)')
          .eq('family_id', familyId)
          .order('created_at', ascending: false)
          .limit(100);

      return (res as List).map((e) => AuditEntry.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return List.unmodifiable(_mockAuditLogs.where((l) => l.familyId == familyId));
    }
  }

  /// Identifies persons that have incomplete archival documentation
  /// (e.g. missing birth date, missing birthplace, unverified, or disconnected from parents)
  Future<List<Person>> getIncompleteRecords(
    String familyId,
    FamilyMembership? membership,
  ) async {
    SecurityGuards.assertCanRead(membership);

    final allPersons = await _personRepo.getPersonsForFamily(familyId, membership);
    final relationships = await _relationshipRepo.getRelationshipsForFamily(familyId, membership);

    final childPersonIds = relationships
        .where((r) => r.type == RelationshipType.parent)
        .map((r) => r.relatedPersonId)
        .toSet();

    return allPersons.where((p) {
      final missingBirth = p.birthDate == null && p.birthYearApprox == null;
      final missingPlace = p.birthPlace == null || p.birthPlace!.trim().isEmpty;
      final unverified = !p.isVerified;
      // If not gen 1, check if missing parents
      final isDisconnected = (p.generationHint == null || p.generationHint! > 1) &&
          !childPersonIds.contains(p.id);

      return missingBirth || missingPlace || unverified || isDisconnected;
    }).toList();
  }

  /// Exports the entire family archive as a formatted JSON document for archival backup & recovery
  Future<String> exportArchiveJson(
    String familyId,
    FamilyMembership? membership,
  ) async {
    SecurityGuards.assertPrimaryAdmin(membership, operation: 'export family archive');

    if (_supabase.isInitialized) {
      try {
        final res = await _supabase.client.rpc('export_family_archive', params: {
          'p_family_id': familyId,
        });
        return const JsonEncoder.withIndent('  ').convert(res);
      } catch (_) {
        // Fallback to local composition
      }
    }

    final persons = await _personRepo.getPersonsForFamily(familyId, membership);
    final relationships = await _relationshipRepo.getRelationshipsForFamily(familyId, membership);
    final media = await _mediaRepo.getMediaForFamily(familyId, membership);
    final events = await _timelineRepo.getTimelineEvents(familyId, membership);

    final archiveMap = {
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'version': '1.0.0',
      'family_id': familyId,
      'stats': {
        'total_persons': persons.length,
        'total_relationships': relationships.length,
        'total_media_assets': media.length,
        'total_life_events': events.length,
      },
      'persons': persons.map((p) => p.toJson()).toList(),
      'relationships': relationships.map((r) => r.toJson()).toList(),
      'life_events': events.map((e) => {
        'id': e.id,
        'event_type': e.eventType.dbValue,
        'title': e.title,
        'description': e.description,
        'event_date': e.eventDate?.toIso8601String(),
        'location': e.location,
        'linked_persons': e.linkedPersonIds,
      }).toList(),
      'media_assets': media.map((m) => {
        'id': m.id,
        'media_type': m.mediaType.dbValue,
        'title': m.title,
        'storage_path': m.storagePath,
        'captured_date': m.capturedDate?.toIso8601String(),
        'file_size': m.fileSizeBytes,
      }).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(archiveMap);
  }

  void _initSampleAuditLogs() {
    const famId = 'fam_kensington_01';
    final now = DateTime.now();

    _mockAuditLogs.addAll([
      AuditEntry(
        id: 'aud_01',
        familyId: famId,
        actorId: 'usr_admin_kensington_01',
        action: 'create_family_archive',
        entityType: 'family',
        entityId: famId,
        payload: {'name': 'The Kensington Heritage'},
        createdAt: now.subtract(const Duration(days: 30)),
        actorEmail: 'heritage.archon@familylegacy.org',
      ),
      AuditEntry(
        id: 'aud_02',
        familyId: famId,
        actorId: 'usr_admin_kensington_01',
        action: 'seed_ten_generations',
        entityType: 'persons',
        entityId: 'p_gen1_archibald',
        payload: {'count': 17, 'generations': 10},
        createdAt: now.subtract(const Duration(days: 14)),
        actorEmail: 'heritage.archon@familylegacy.org',
      ),
      AuditEntry(
        id: 'aud_03',
        familyId: famId,
        actorId: 'usr_admin_kensington_01',
        action: 'approve_member',
        entityType: 'membership_requests',
        entityId: 'req_clara',
        payload: {'approved_user_id': 'usr_viewer_01', 'role': 'viewer'},
        createdAt: now.subtract(const Duration(days: 2)),
        actorEmail: 'heritage.archon@familylegacy.org',
      ),
    ]);
  }
}
