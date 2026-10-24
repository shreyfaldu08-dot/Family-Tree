/// Configuration settings for Supabase backend
abstract final class SupabaseConfig {
  /// Default development / demo credentials
  /// In production, these should be supplied via compile-time environment variables:
  /// `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://oprsufxivnrpevkdjghx.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.e30.demo_anon_key_for_family_legacy',
  );

  static const String mediaBucket = 'family-legacy-private';

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty &&
      !supabaseUrl.contains('example') &&
      !supabaseAnonKey.contains('demo_anon_key');
}
