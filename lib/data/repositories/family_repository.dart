import 'dart:math';
import '../models/family.dart';
import '../models/membership.dart';
import '../models/invitation.dart';
import '../services/supabase_service.dart';
import '../../core/security/security_guards.dart';

class FamilyRepository {
  final SupabaseService _supabase;

  // Local fallback state
  Family? _currentFamily;
  final List<FamilyMembership> _memberships = [];
  final List<MembershipRequest> _requests = [];
  final List<Invitation> _invitations = [];

  FamilyRepository({required SupabaseService supabase}) : _supabase = supabase {
    _initSampleFamily();
  }

  Future<Family?> getFamily(String familyId, FamilyMembership? membership) async {
    if (!_supabase.isInitialized) {
      return _currentFamily;
    }

    SecurityGuards.assertCanRead(membership);

    try {
      final res = await _supabase.client
          .from('families')
          .select()
          .eq('id', familyId)
          .maybeSingle();

      if (res != null) {
        return Family.fromJson(res);
      }
      return _currentFamily;
    } catch (_) {
      return _currentFamily;
    }
  }

  Future<List<FamilyMembership>> getMembers(
    String familyId,
    FamilyMembership? membership,
  ) async {
    SecurityGuards.assertCanRead(membership);

    if (!_supabase.isInitialized) {
      return List.unmodifiable(_memberships.where((m) => m.familyId == familyId));
    }

    try {
      final res = await _supabase.client
          .from('family_memberships')
          .select('*, profiles(*)')
          .eq('family_id', familyId);

      return (res as List).map((e) => FamilyMembership.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return List.unmodifiable(_memberships.where((m) => m.familyId == familyId));
    }
  }

  Future<List<MembershipRequest>> getPendingRequests(
    String familyId,
    FamilyMembership? membership,
  ) async {
    SecurityGuards.assertPrimaryAdmin(membership, operation: 'view pending membership requests');

    if (!_supabase.isInitialized) {
      return List.unmodifiable(
        _requests.where((r) => r.familyId == familyId && r.status == 'pending'),
      );
    }

    try {
      final res = await _supabase.client
          .from('membership_requests')
          .select('*, profiles(*)')
          .eq('family_id', familyId)
          .eq('status', 'pending');

      return (res as List).map((e) => MembershipRequest.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return List.unmodifiable(
        _requests.where((r) => r.familyId == familyId && r.status == 'pending'),
      );
    }
  }

  Future<void> approveRequest(
    String requestId,
    FamilyMembership? membership,
  ) async {
    SecurityGuards.assertPrimaryAdmin(membership, operation: 'approve membership requests');

    if (!_supabase.isInitialized) {
      final idx = _requests.indexWhere((r) => r.id == requestId);
      if (idx != -1) {
        final req = _requests[idx];
        _memberships.add(FamilyMembership(
          id: 'mem_${req.userId}',
          familyId: req.familyId,
          userId: req.userId,
          role: MemberRole.viewer,
          status: MemberStatus.active,
          joinedAt: DateTime.now(),
          updatedAt: DateTime.now(),
          userEmail: req.requesterEmail,
          userDisplayName: req.requesterDisplayName,
        ));
        _requests.removeAt(idx);
      }
      return;
    }

    try {
      await _supabase.client.rpc('approve_membership_request', params: {
        'p_request_id': requestId,
      });
    } catch (_) {
      final idx = _requests.indexWhere((r) => r.id == requestId);
      if (idx != -1) _requests.removeAt(idx);
    }
  }

  Future<void> rejectRequest(
    String requestId,
    FamilyMembership? membership,
  ) async {
    SecurityGuards.assertPrimaryAdmin(membership, operation: 'reject membership requests');

    if (!_supabase.isInitialized) {
      _requests.removeWhere((r) => r.id == requestId);
      return;
    }

    try {
      await _supabase.client.rpc('reject_membership_request', params: {
        'p_request_id': requestId,
      });
    } catch (_) {
      _requests.removeWhere((r) => r.id == requestId);
    }
  }

  Future<void> revokeMembership(
    String membershipId,
    FamilyMembership? membership,
  ) async {
    SecurityGuards.assertPrimaryAdmin(membership, operation: 'revoke family members');

    if (!_supabase.isInitialized) {
      final idx = _memberships.indexWhere((m) => m.id == membershipId);
      if (idx != -1) {
        _memberships[idx] = FamilyMembership(
          id: _memberships[idx].id,
          familyId: _memberships[idx].familyId,
          userId: _memberships[idx].userId,
          role: _memberships[idx].role,
          status: MemberStatus.revoked,
          joinedAt: _memberships[idx].joinedAt,
          updatedAt: DateTime.now(),
          userEmail: _memberships[idx].userEmail,
          userDisplayName: _memberships[idx].userDisplayName,
        );
      }
      return;
    }

    try {
      await _supabase.client.rpc('revoke_membership', params: {
        'p_membership_id': membershipId,
      });
    } catch (_) {
      _memberships.removeWhere((m) => m.id == membershipId);
    }
  }

  /// Generates a single-use random invitation token, stores its SHA-256 hash
  Future<String> createInvitation({
    required String familyId,
    String? recipientEmail,
    required Duration validity,
    required FamilyMembership? membership,
  }) async {
    SecurityGuards.assertPrimaryAdmin(membership, operation: 'generate family invitations');

    // Generate random 8-character token (e.g. LEGACY-7K2X)
    final rand = Random.secure();
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final token = 'HL-${List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join()}';
    final tokenHash = SupabaseService.hashInvitationCode(token);
    final expiresAt = DateTime.now().add(validity);

    if (!_supabase.isInitialized) {
      _invitations.add(Invitation(
        id: 'inv_${DateTime.now().millisecondsSinceEpoch}',
        familyId: familyId,
        codeHash: tokenHash,
        recipientEmail: recipientEmail,
        createdBy: membership?.userId ?? '',
        expiresAt: expiresAt,
        isRevoked: false,
        createdAt: DateTime.now(),
      ));
      return token;
    }

    try {
      await _supabase.client.from('invitations').insert({
        'family_id': familyId,
        'code_hash': tokenHash,
        'recipient_email': recipientEmail,
        'created_by': membership?.userId ?? '',
        'expires_at': expiresAt.toIso8601String(),
        'is_revoked': false,
      });
      return token;
    } catch (_) {
      return token;
    }
  }

  /// Redeem an invitation token and submit a membership request
  Future<void> redeemInvitation({
    required String rawCode,
    String? note,
  }) async {
    final tokenHash = SupabaseService.hashInvitationCode(rawCode);

    if (!_supabase.isInitialized) {
      final inv = _invitations.firstWhere(
        (i) => i.codeHash == tokenHash && i.isValid,
        orElse: () => throw Exception('Invalid or expired invitation code.'),
      );

      _requests.add(MembershipRequest(
        id: 'req_${DateTime.now().millisecondsSinceEpoch}',
        familyId: inv.familyId,
        userId: 'current_user',
        invitationId: inv.id,
        note: note,
        status: 'pending',
        createdAt: DateTime.now(),
        requesterEmail: 'applicant@example.com',
        requesterDisplayName: 'Heritage Applicant',
      ));
      return;
    }

    try {
      await _supabase.client.rpc('redeem_invitation_and_request', params: {
        'p_code_hash': tokenHash,
        'p_note': note,
      });
    } catch (e) {
      throw Exception('Redemption error: $e');
    }
  }

  void _initSampleFamily() {
    final now = DateTime.now();
    _currentFamily = Family(
      id: 'fam_kensington_01',
      name: 'The Kensington Heritage',
      motto: 'Radices Altae, Rami Fortes (Deep Roots, Strong Branches)',
      description: 'An unbroken ten-generation family record chronicling four centuries of living memory.',
      originPlace: 'Edinburgh, Scotland',
      createdBy: 'usr_admin_kensington_01',
      createdAt: now,
      updatedAt: now,
    );

    _memberships.add(FamilyMembership(
      id: 'mem_admin_01',
      familyId: 'fam_kensington_01',
      userId: 'usr_admin_kensington_01',
      role: MemberRole.primaryAdmin,
      status: MemberStatus.active,
      joinedAt: now,
      updatedAt: now,
      userEmail: 'heritage.archon@familylegacy.org',
      userDisplayName: 'Archon Kensington (Primary Admin)',
    ));

    _memberships.add(FamilyMembership(
      id: 'mem_viewer_01',
      familyId: 'fam_kensington_01',
      userId: 'usr_viewer_01',
      role: MemberRole.viewer,
      status: MemberStatus.active,
      joinedAt: now,
      updatedAt: now,
      userEmail: 'clara.reader@gmail.com',
      userDisplayName: 'Clara Reader (Approved Family Member)',
    ));
  }
}
