/// Build-time configuration. Supply with:
///   flutter run --dart-define-from-file=env.json
/// Only the public anon key belongs here. NEVER put the service-role key in the app.
class AppConfig {
  const AppConfig._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Must also be added under Supabase > Authentication > URL Configuration > Redirect URLs.
  static const passwordResetRedirect = 'campuscare://reset-password';

  static void assertConfigured() {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw StateError(
        'Missing SUPABASE_URL / SUPABASE_ANON_KEY. '
        'Run with --dart-define-from-file=env.json (see env.example.json).',
      );
    }
  }
}
