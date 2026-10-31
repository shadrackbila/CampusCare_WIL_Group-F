import 'package:shared_preferences/shared_preferences.dart';

/// Local-only preferences about the session. No credentials are ever stored here;
/// Supabase Auth owns the session and passwords.
class SessionPreferences {
  static const _rememberKey = 'remember_me';

  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberKey) ?? true;
  }

  Future<void> setRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberKey, value);
  }
}
