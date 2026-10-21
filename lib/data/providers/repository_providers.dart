import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';
import '../services/secure_storage_service.dart';
import '../repositories/auth_repository.dart';
import '../repositories/family_repository.dart';
import '../repositories/person_repository.dart';
import '../repositories/relationship_repository.dart';
import '../repositories/media_repository.dart';
import '../repositories/timeline_repository.dart';
import '../repositories/admin_repository.dart';
import '../models/profile.dart';
import '../models/membership.dart';
import '../models/family.dart';
import '../models/person.dart';
import '../models/relationship.dart';
import '../models/media_asset.dart';
import '../models/life_event.dart';

// -----------------------------------------------------------------------------
// Core Services
// -----------------------------------------------------------------------------
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

// -----------------------------------------------------------------------------
// Repositories
// -----------------------------------------------------------------------------
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    supabase: ref.watch(supabaseServiceProvider),
    storage: ref.watch(secureStorageServiceProvider),
  );
});

final familyRepositoryProvider = Provider<FamilyRepository>((ref) {
  return FamilyRepository(supabase: ref.watch(supabaseServiceProvider));
});

final personRepositoryProvider = Provider<PersonRepository>((ref) {
  return PersonRepository(supabase: ref.watch(supabaseServiceProvider));
});

final relationshipRepositoryProvider = Provider<RelationshipRepository>((ref) {
  return RelationshipRepository(supabase: ref.watch(supabaseServiceProvider));
});

final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  return MediaRepository(supabase: ref.watch(supabaseServiceProvider));
});

final timelineRepositoryProvider = Provider<TimelineRepository>((ref) {
  return TimelineRepository(supabase: ref.watch(supabaseServiceProvider));
});

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(
    supabase: ref.watch(supabaseServiceProvider),
    personRepo: ref.watch(personRepositoryProvider),
    relationshipRepo: ref.watch(relationshipRepositoryProvider),
    mediaRepo: ref.watch(mediaRepositoryProvider),
    timelineRepo: ref.watch(timelineRepositoryProvider),
  );
});

// -----------------------------------------------------------------------------
// State Providers: Active Family & Auth Session
// -----------------------------------------------------------------------------
class ActiveFamilyIdNotifier extends Notifier<String> {
  @override
  String build() => 'fam_kensington_01';
  void setFamilyId(String id) => state = id;
}

final activeFamilyIdProvider = NotifierProvider<ActiveFamilyIdNotifier, String>(ActiveFamilyIdNotifier.new);

final currentProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  return await repo.getCurrentUserProfile();
});

final currentMembershipProvider = FutureProvider<FamilyMembership?>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  final familyId = ref.watch(activeFamilyIdProvider);
  return await repo.getActiveMembership(familyId);
});

final currentFamilyProvider = FutureProvider<Family?>((ref) async {
  final familyRepo = ref.watch(familyRepositoryProvider);
  final familyId = ref.watch(activeFamilyIdProvider);
  final membership = ref.watch(currentMembershipProvider).valueOrNull;
  return await familyRepo.getFamily(familyId, membership);
});

// -----------------------------------------------------------------------------
// Data Providers (Scoped to active family & membership)
// -----------------------------------------------------------------------------
final familyPersonsProvider = FutureProvider<List<Person>>((ref) async {
  final personRepo = ref.watch(personRepositoryProvider);
  final familyId = ref.watch(activeFamilyIdProvider);
  final membership = ref.watch(currentMembershipProvider).valueOrNull;
  return await personRepo.getPersonsForFamily(familyId, membership);
});

final familyRelationshipsProvider = FutureProvider<List<Relationship>>((ref) async {
  final relRepo = ref.watch(relationshipRepositoryProvider);
  final familyId = ref.watch(activeFamilyIdProvider);
  final membership = ref.watch(currentMembershipProvider).valueOrNull;
  return await relRepo.getRelationshipsForFamily(familyId, membership);
});

final familyMediaProvider = FutureProvider<List<MediaAsset>>((ref) async {
  final mediaRepo = ref.watch(mediaRepositoryProvider);
  final familyId = ref.watch(activeFamilyIdProvider);
  final membership = ref.watch(currentMembershipProvider).valueOrNull;
  return await mediaRepo.getMediaForFamily(familyId, membership);
});

final familyTimelineProvider = FutureProvider<List<LifeEvent>>((ref) async {
  final timelineRepo = ref.watch(timelineRepositoryProvider);
  final familyId = ref.watch(activeFamilyIdProvider);
  final membership = ref.watch(currentMembershipProvider).valueOrNull;
  return await timelineRepo.getTimelineEvents(familyId, membership);
});

extension AsyncValueExtension<T> on AsyncValue<T> {
  T? get valueOrNull => asData?.value;
}
