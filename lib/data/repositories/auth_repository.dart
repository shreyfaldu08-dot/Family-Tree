import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../models/profile.dart';
import '../models/membership.dart';
import '../services/supabase_service.dart';
import '../services/secure_storage_service.dart';
import '../../core/errors/app_exception.dart';

class AuthRepository {
  final SupabaseService _supabase;
  final SecureStorageService _storage;

  // In-memory mock/fallback state for offline, local testing & previews
  UserProfile? _mockProfile;
  FamilyMembership? _mockMembership;

  AuthRepository({
    required SupabaseService supabase,
    required SecureStorageService storage,
  })  : _supabase = supabase,
        _storage = storage {
    _initDefaultSession();
  }

  void _initDefaultSession() {
    _mockProfile ??= UserProfile(
      id: 'usr_admin_kensington_01',
      email: 'archon@vansora.heritage',
      displayName: 'Family Archon',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _mockMembership ??= FamilyMembership(
      id: 'mem_admin_01',
      familyId: 'fam_kensington_01',
      userId: _mockProfile!.id,
      role: MemberRole.primaryAdmin,
      status: MemberStatus.active,
      joinedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  bool get isAuthenticated {
    if (_supabase.isInitialized && _supabase.currentUser != null) {
      return true;
    }
    return _mockProfile != null;
  }

  String? get currentUserId {
    if (_supabase.isInitialized) {
      return _supabase.currentUser?.id;
    }
    return _mockProfile?.id;
  }

  Future<UserProfile?> getCurrentUserProfile() async {
    if (!_supabase.isInitialized) {
      return _mockProfile;
    }

    final user = _supabase.currentUser;
    if (user == null) return _mockProfile;

    try {
      final res = await _supabase.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (res != null) {
        return UserProfile.fromJson(res);
      }

      // If user exists in auth but not yet in profiles, create entry
      final newProfile = UserProfile(
        id: user.id,
        email: user.email ?? '',
        displayName: user.userMetadata?['display_name'] as String?,
        avatarUrl: user.userMetadata?['avatar_url'] as String?,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _supabase.client.from('profiles').upsert(newProfile.toJson());
      return newProfile;
    } catch (_) {
      return _mockProfile ??
          UserProfile(
            id: user.id,
            email: user.email ?? '',
            displayName: user.email?.split('@').first,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
    }
  }

  Future<FamilyMembership?> getActiveMembership(String familyId) async {
    if (!_supabase.isInitialized) {
      return _mockMembership;
    }

    final userId = currentUserId;
    if (userId == null) return _mockMembership;

    try {
      final res = await _supabase.client
          .from('family_memberships')
          .select('*, profiles(*)')
          .eq('family_id', familyId)
          .eq('user_id', userId)
          .maybeSingle();

      if (res != null) {
        return FamilyMembership.fromJson(res);
      }
      return _mockMembership;
    } catch (_) {
      return _mockMembership;
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (!_supabase.isInitialized) {
      // Local fallback for offline/preview
      _mockProfile = UserProfile(
        id: 'usr_admin_kensington_01',
        email: email,
        displayName: email.split('@').first,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _mockMembership = FamilyMembership(
        id: 'mem_admin_01',
        familyId: 'fam_kensington_01',
        userId: _mockProfile!.id,
        role: MemberRole.primaryAdmin,
        status: MemberStatus.active,
        joinedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _storage.saveUserSession(_mockProfile!.id);
      await _storage.saveActiveFamilyId(_mockMembership!.familyId);
      return;
    }

    try {
      final response = await _supabase.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user == null) {
        throw const AuthException('Sign in failed. Invalid credentials.');
      }

      await _storage.saveUserSession(response.session?.accessToken ?? '');
    } on sb.AuthException catch (e) {
      throw AuthException(e.message, code: e.statusCode);
    } catch (e) {
      throw AuthException('An unexpected error occurred during sign in: $e');
    }
  }

  Future<void> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (!_supabase.isInitialized) {
      _mockProfile = UserProfile(
        id: 'usr_reg_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: displayName ?? email.split('@').first,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _mockMembership = FamilyMembership(
        id: 'mem_${DateTime.now().millisecondsSinceEpoch}',
        familyId: 'fam_kensington_01',
        userId: _mockProfile!.id,
        role: MemberRole.primaryAdmin,
        status: MemberStatus.active,
        joinedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _storage.saveUserSession(_mockProfile!.id);
      await _storage.saveActiveFamilyId(_mockMembership!.familyId);
      return;
    }

    try {
      final response = await _supabase.client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'display_name': displayName?.trim(),
        },
      );

      if (response.user == null) {
        throw const AuthException('Registration failed. Please try again.');
      }

      // Upsert profile
      await _supabase.client.from('profiles').upsert({
        'id': response.user!.id,
        'email': email.trim(),
        'display_name': displayName?.trim(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } on sb.AuthException catch (e) {
      throw AuthException(e.message, code: e.statusCode);
    } catch (e) {
      throw AuthException('Registration error: $e');
    }
  }

  Future<void> signInWithGoogle() async {
    if (!_supabase.isInitialized) {
      _mockProfile = UserProfile(
        id: 'usr_google_admin_01',
        email: 'heritage.keeper@gmail.com',
        displayName: 'Family Archon',
        avatarUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _mockMembership = FamilyMembership(
        id: 'mem_google_admin',
        familyId: 'fam_kensington_01',
        userId: _mockProfile!.id,
        role: MemberRole.primaryAdmin,
        status: MemberStatus.active,
        joinedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _storage.saveUserSession(_mockProfile!.id);
      await _storage.saveActiveFamilyId(_mockMembership!.familyId);
      return;
    }

    try {
      await _supabase.client.auth.signInWithOAuth(
        sb.OAuthProvider.google,
        redirectTo: 'familylegacy://login-callback',
      );
    } on sb.AuthException catch (e) {
      throw AuthException(e.message, code: e.statusCode);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    if (!_supabase.isInitialized) return;
    try {
      await _supabase.client.auth.resetPasswordForEmail(email.trim());
    } on sb.AuthException catch (e) {
      throw AuthException(e.message, code: e.statusCode);
    }
  }

  Future<void> signOut() async {
    _mockProfile = null;
    _mockMembership = null;
    await _storage.clearAll();

    if (_supabase.isInitialized) {
      try {
        await _supabase.client.auth.signOut();
      } catch (_) {}
    }
  }

  void setMockSession({
    required UserProfile profile,
    required FamilyMembership membership,
  }) {
    _mockProfile = profile;
    _mockMembership = membership;
  }
}
