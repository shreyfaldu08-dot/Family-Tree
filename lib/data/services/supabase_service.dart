import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';

class SupabaseService {
  SupabaseClient? _client;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  SupabaseClient get client {
    if (_client == null) {
      try {
        _client = Supabase.instance.client;
        _isInitialized = true;
      } catch (_) {
        // Not initialized yet
      }
    }
    return _client!;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    if (!SupabaseConfig.isConfigured) {
      _isInitialized = false;
      return;
    }

    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );
      _client = Supabase.instance.client;
      _isInitialized = true;
    } catch (e) {
      // In offline/test environments, initialize safely
      _isInitialized = false;
    }
  }

  User? get currentUser {
    if (!_isInitialized) return null;
    try {
      return client.auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  Session? get currentSession {
    if (!_isInitialized) return null;
    try {
      return client.auth.currentSession;
    } catch (_) {
      return null;
    }
  }

  Stream<AuthState>? get authStateChanges {
    if (!_isInitialized) return null;
    try {
      return client.auth.onAuthStateChange;
    } catch (_) {
      return null;
    }
  }

  /// Hash invitation token with SHA-256 before sending or looking up in DB
  static String hashInvitationCode(String rawCode) {
    final cleanCode = rawCode.trim().toUpperCase();
    final bytes = utf8.encode(cleanCode);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generates a short-lived signed URL (e.g. 1 hour) for private storage media
  Future<String?> getSignedMediaUrl(String storagePath, {int expiresInSeconds = 3600}) async {
    if (!_isInitialized || storagePath.isEmpty) return null;
    try {
      final signedUrl = await client.storage
          .from(SupabaseConfig.mediaBucket)
          .createSignedUrl(storagePath, expiresInSeconds);
      return signedUrl;
    } catch (_) {
      return null;
    }
  }
}
