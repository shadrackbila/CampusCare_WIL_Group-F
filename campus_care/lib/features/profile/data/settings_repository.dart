import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../models/user_settings.dart';

abstract class SettingsRepository {
  Future<UserSettings> fetch(String userId);
  Future<void> save(String userId, UserSettings settings);
}

class SupabaseSettingsRepository implements SettingsRepository {
  SupabaseSettingsRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<UserSettings> fetch(String userId) async {
    try {
      final row = await _client
          .from('user_settings')
          .select(UserSettings.selectColumns)
          .eq('user_id', userId)
          .maybeSingle();
      return row == null ? const UserSettings() : UserSettings.fromJson(row);
    } catch (e, s) {
      throw AppException.from(e, s);
    }
  }

  /// Upsert, so an account created before the signup trigger existed still works.
  @override
  Future<void> save(String userId, UserSettings settings) async {
    try {
      await _client.from('user_settings').upsert({
        'user_id': userId,
        ...settings.toJson(),
      });
    } catch (e, s) {
      throw AppException.from(e, s);
    }
  }
}
