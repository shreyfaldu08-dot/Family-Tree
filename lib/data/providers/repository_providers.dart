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
import '../models/correction_request.dart';
import '../models/app_user.dart';
import '../models/audit_entry.dart';
import '../models/branch_join_request.dart';

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

class CurrentUserRoleNotifier extends Notifier<MemberRole> {
  @override
  MemberRole build() {
    return MemberRole.primaryAdmin;
  }

  void setRole(MemberRole newRole) {
    state = newRole;
    final authRepo = ref.read(authRepositoryProvider);
    authRepo.setRole(newRole);
    ref.invalidate(currentMembershipProvider);
    ref.invalidate(familyPersonsProvider);
    ref.invalidate(familyRelationshipsProvider);
    ref.invalidate(familyMediaProvider);
    ref.invalidate(familyTimelineProvider);
  }

  void toggleRole() {
    setRole(state == MemberRole.primaryAdmin ? MemberRole.viewer : MemberRole.primaryAdmin);
  }
}

final currentUserRoleProvider = NotifierProvider<CurrentUserRoleNotifier, MemberRole>(CurrentUserRoleNotifier.new);

final isCurrentAdminProvider = Provider<bool>((ref) {
  final role = ref.watch(currentUserRoleProvider);
  final membership = ref.watch(currentMembershipProvider).valueOrNull;
  if (role == MemberRole.viewer) return false;
  return membership?.canWriteFamilyData ?? (role == MemberRole.primaryAdmin);
});

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

// -----------------------------------------------------------------------------
// Admin Settings State & Provider
// -----------------------------------------------------------------------------
class AdminSettingsState {
  final bool allowCorrectionSuggestions;
  final bool hideSensitiveLivingDetails;
  final bool allowUserDownloads;
  final String activeLanguage; // 'en', 'hi', 'gu'

  const AdminSettingsState({
    this.allowCorrectionSuggestions = true,
    this.hideSensitiveLivingDetails = true,
    this.allowUserDownloads = true,
    this.activeLanguage = 'en',
  });

  AdminSettingsState copyWith({
    bool? allowCorrectionSuggestions,
    bool? hideSensitiveLivingDetails,
    bool? allowUserDownloads,
    String? activeLanguage,
  }) {
    return AdminSettingsState(
      allowCorrectionSuggestions: allowCorrectionSuggestions ?? this.allowCorrectionSuggestions,
      hideSensitiveLivingDetails: hideSensitiveLivingDetails ?? this.hideSensitiveLivingDetails,
      allowUserDownloads: allowUserDownloads ?? this.allowUserDownloads,
      activeLanguage: activeLanguage ?? this.activeLanguage,
    );
  }
}

class AdminSettingsNotifier extends Notifier<AdminSettingsState> {
  @override
  AdminSettingsState build() => const AdminSettingsState();

  void toggleCorrectionSuggestions() {
    state = state.copyWith(allowCorrectionSuggestions: !state.allowCorrectionSuggestions);
  }

  void toggleHideSensitiveLivingDetails() {
    state = state.copyWith(hideSensitiveLivingDetails: !state.hideSensitiveLivingDetails);
  }

  void toggleAllowUserDownloads() {
    state = state.copyWith(allowUserDownloads: !state.allowUserDownloads);
  }

  void setLanguage(String lang) {
    state = state.copyWith(activeLanguage: lang);
  }
}

final adminSettingsProvider = NotifierProvider<AdminSettingsNotifier, AdminSettingsState>(AdminSettingsNotifier.new);

// -----------------------------------------------------------------------------
// Correction Requests Notifier & Provider
// -----------------------------------------------------------------------------
class CorrectionRequestsNotifier extends Notifier<List<CorrectionRequest>> {
  @override
  List<CorrectionRequest> build() {
    return [
      CorrectionRequest(
        id: 'cr_1',
        userId: 'usr_viewer_01',
        userName: 'Aarav Patel',
        personId: 'p_gen1_archibald',
        personName: 'Archibald Kensington',
        message: 'Archibald was born in Edinburgh Old Town, not Lowlands according to parish records.',
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      CorrectionRequest(
        id: 'cr_2',
        userId: 'usr_viewer_02',
        userName: 'Diya Sharma',
        personId: 'p_gen1_margaret',
        personName: 'Margaret Kensington',
        message: 'Middle name was listed as Elizabeth in her wedding register.',
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  void addRequest(CorrectionRequest req) {
    state = [req, ...state];
  }

  void acceptRequest(String id) {
    state = [
      for (final req in state)
        if (req.id == id) req.copyWith(status: 'accepted') else req
    ];
  }

  void rejectRequest(String id) {
    state = [
      for (final req in state)
        if (req.id == id) req.copyWith(status: 'rejected') else req
    ];
  }
}

final correctionRequestsProvider = NotifierProvider<CorrectionRequestsNotifier, List<CorrectionRequest>>(CorrectionRequestsNotifier.new);

// -----------------------------------------------------------------------------
// User Management Notifier & Provider
// -----------------------------------------------------------------------------
class UserManagementNotifier extends Notifier<List<AppUser>> {
  @override
  List<AppUser> build() {
    return [
      AppUser(
        id: 'usr_1',
        name: 'Master Archon (Primary)',
        emailOrPhone: 'heritage.archon@familylegacy.org',
        role: 'admin',
        isBlocked: false,
        language: 'en',
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
      ),
      AppUser(
        id: 'usr_2',
        name: 'Kavita Patel',
        emailOrPhone: 'kavita.p@gmail.com',
        role: 'user',
        isBlocked: false,
        language: 'gu',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
      AppUser(
        id: 'usr_3',
        name: 'Rohan Mehta',
        emailOrPhone: '+91 98765 43210',
        role: 'user',
        isBlocked: false,
        language: 'hi',
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
      ),
      AppUser(
        id: 'usr_4',
        name: 'Ananya Desai',
        emailOrPhone: 'ananya.desai@outlook.com',
        role: 'user',
        isBlocked: true,
        language: 'en',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
    ];
  }

  void toggleBlock(String userId) {
    state = [
      for (final u in state)
        if (u.id == userId) u.copyWith(isBlocked: !u.isBlocked) else u
    ];
  }

  void deleteUser(String userId) {
    state = state.where((u) => u.id != userId).toList();
  }

  void addAdmin({required String name, required String emailOrPhone}) {
    final newUser = AppUser(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      emailOrPhone: emailOrPhone,
      role: 'admin',
      isBlocked: false,
      language: 'en',
      createdAt: DateTime.now(),
    );
    state = [...state, newUser];
  }
}

final userManagementProvider = NotifierProvider<UserManagementNotifier, List<AppUser>>(UserManagementNotifier.new);

// -----------------------------------------------------------------------------
// Audit Logs Notifier with Undo Capability
// -----------------------------------------------------------------------------
class AuditLogsNotifier extends Notifier<List<AuditEntry>> {
  @override
  List<AuditEntry> build() {
    final now = DateTime.now();
    return [
      AuditEntry(
        id: 'log_1',
        familyId: 'fam_kensington_01',
        actorId: 'usr_1',
        actorEmail: 'admin@vansora.family',
        action: 'add_person',
        entityType: 'person',
        entityId: 'p_gen1_archibald',
        payload: {'name': 'Archibald Kensington', 'details': 'Created root ancestor patriarch'},
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      AuditEntry(
        id: 'log_2',
        familyId: 'fam_kensington_01',
        actorId: 'usr_1',
        actorEmail: 'admin@vansora.family',
        action: 'link_relationship',
        entityType: 'relationship',
        entityId: 'rel_sp_1',
        payload: {'details': 'Linked Margaret Kensington as spouse of Archibald'},
        createdAt: now.subtract(const Duration(hours: 1, minutes: 40)),
      ),
      AuditEntry(
        id: 'log_3',
        familyId: 'fam_kensington_01',
        actorId: 'usr_1',
        actorEmail: 'admin@vansora.family',
        action: 'upload_media',
        entityType: 'media',
        entityId: 'med_01',
        payload: {'details': 'Archival scan: 1745 Stone Masonry Guild Charter'},
        createdAt: now.subtract(const Duration(minutes: 45)),
      ),
    ];
  }

  void logAction({
    required String action,
    required String entityType,
    required String entityId,
    required Map<String, dynamic> payload,
  }) {
    final entry = AuditEntry(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      familyId: 'fam_kensington_01',
      actorId: 'usr_admin',
      actorEmail: 'admin@vansora.family',
      action: action,
      entityType: entityType,
      entityId: entityId,
      payload: payload,
      createdAt: DateTime.now(),
    );
    state = [entry, ...state];
  }

  void undoAction(String logId) {
    state = state.where((l) => l.id != logId).toList();
  }
}

final auditLogsNotifierProvider = NotifierProvider<AuditLogsNotifier, List<AuditEntry>>(AuditLogsNotifier.new);

// -----------------------------------------------------------------------------
// Unique Family Tree ID & Branch Administration System
// -----------------------------------------------------------------------------
enum BranchViewMode { myBranch, fullTree }

class UniqueFamilyTreeIdNotifier extends Notifier<String> {
  @override
  String build() => 'VANS-8842';
  void setTreeId(String id) => state = id.trim().toUpperCase();
}

final uniqueFamilyTreeIdProvider = NotifierProvider<UniqueFamilyTreeIdNotifier, String>(UniqueFamilyTreeIdNotifier.new);

class BranchViewModeNotifier extends Notifier<BranchViewMode> {
  @override
  BranchViewMode build() => BranchViewMode.myBranch;
  void toggle() => state = state == BranchViewMode.myBranch ? BranchViewMode.fullTree : BranchViewMode.myBranch;
  void setMode(BranchViewMode mode) => state = mode;
}

final branchViewModeProvider = NotifierProvider<BranchViewModeNotifier, BranchViewMode>(BranchViewModeNotifier.new);

class UserBranchPersonIdNotifier extends Notifier<String?> {
  @override
  String? build() => 'per_hamish'; // Default active logged-in brother/branch head
  void setPersonId(String? id) => state = id;
}

final userBranchPersonIdProvider = NotifierProvider<UserBranchPersonIdNotifier, String?>(UserBranchPersonIdNotifier.new);

class BranchJoinRequestsNotifier extends Notifier<List<BranchJoinRequest>> {
  @override
  List<BranchJoinRequest> build() {
    final now = DateTime.now();
    return [
      BranchJoinRequest(
        id: 'req_branch_01',
        treeId: 'VANS-8842',
        applicantName: 'David Kensington',
        applicantEmail: 'david.kensington@clan.org',
        applicantGender: 'male',
        applicantHometown: 'Edinburgh',
        fatherName: 'Hamish Kensington',
        fatherLiving: false,
        motherName: 'Isla Kensington',
        motherMaidenName: 'Sinclair',
        grandfatherName: 'Archibald Kensington',
        grandfatherLiving: false,
        grandmotherName: 'Margaret Kensington',
        grandmotherMaidenName: 'MacLeod',
        matchedGrandfatherId: 'per_archibald',
        matchedGrandfatherName: 'Archibald Kensington',
        matchedFatherId: 'per_hamish',
        matchedFatherName: 'Hamish Kensington',
        status: 'pending',
        submittedAt: now.subtract(const Duration(hours: 3)),
      ),
      BranchJoinRequest(
        id: 'req_branch_02',
        treeId: 'VANS-8842',
        applicantName: 'Fiona Kensington',
        applicantEmail: 'fiona.k@lineage.org',
        applicantGender: 'female',
        applicantHometown: 'Stirling',
        fatherName: 'Callum Kensington',
        fatherLiving: false,
        motherName: 'Catriona Kensington',
        motherMaidenName: 'Campbell',
        grandfatherName: 'Hamish Kensington',
        grandfatherLiving: false,
        grandmotherName: 'Isla Kensington',
        grandmotherMaidenName: 'Sinclair',
        matchedGrandfatherId: 'per_hamish',
        matchedGrandfatherName: 'Hamish Kensington',
        status: 'pending',
        submittedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  void submitRequest(BranchJoinRequest request) {
    state = [request, ...state];
  }

  void verifyAndConnect(String requestId) {
    state = state.map((req) {
      if (req.id == requestId) {
        return req.copyWith(
          status: 'verified',
          verifiedAt: DateTime.now(),
        );
      }
      return req;
    }).toList();

    // Log the verification in audit trail
    final req = state.firstWhere((r) => r.id == requestId);
    ref.read(auditLogsNotifierProvider.notifier).logAction(
      action: 'verify_branch_connection',
      entityType: 'branch',
      entityId: req.id,
      payload: {
        'applicant': req.applicantName,
        'grandfather': req.grandfatherName,
        'matchedId': req.matchedGrandfatherId,
        'status': 'verified_and_connected',
      },
    );
  }

  void rejectRequest(String requestId) {
    state = state.map((req) {
      if (req.id == requestId) {
        return req.copyWith(
          status: 'rejected',
          verifiedAt: DateTime.now(),
        );
      }
      return req;
    }).toList();
  }
}

final branchJoinRequestsProvider = NotifierProvider<BranchJoinRequestsNotifier, List<BranchJoinRequest>>(BranchJoinRequestsNotifier.new);

// Permission Checker: Main Admin has full rights; User can edit own profile and descendants in their branch
final canEditPersonProvider = Provider.family<bool, String>((ref, targetPersonId) {
  final isMainAdmin = ref.watch(isCurrentAdminProvider);
  if (isMainAdmin) return true;

  final userPersonId = ref.watch(userBranchPersonIdProvider);
  if (userPersonId == null) return false;

  // Rule: User has direct rights to edit their own personal details
  if (userPersonId == targetPersonId) return true;

  // Rule: Branch Admin can edit their branch descendants
  final relationships = ref.watch(familyRelationshipsProvider).valueOrNull ?? [];
  final descendants = _collectDescendants(userPersonId, relationships);
  return descendants.contains(targetPersonId);
});

Set<String> _collectDescendants(String rootId, List<Relationship> relationships) {
  final result = <String>{};
  final queue = <String>[rootId];
  while (queue.isNotEmpty) {
    final current = queue.removeAt(0);
    for (final rel in relationships) {
      if (rel.type == RelationshipType.parent && rel.personId == current) {
        if (!result.contains(rel.relatedPersonId)) {
          result.add(rel.relatedPersonId);
          queue.add(rel.relatedPersonId);
        }
      } else if (rel.type == RelationshipType.child && rel.relatedPersonId == current) {
        if (!result.contains(rel.personId)) {
          result.add(rel.personId);
          queue.add(rel.personId);
        }
      }
    }
  }
  return result;
}


