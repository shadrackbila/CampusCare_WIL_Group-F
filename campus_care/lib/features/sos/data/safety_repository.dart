import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../models/emergency_contact.dart';

abstract class SafetyRepository {
  Future<List<EmergencyContact>> fetchContacts();

  /// action: 'call_emergency' | 'call_wellness_centre' | 'open_peer_chat'
  Future<void> logSos(String studentId, String action);
}

class SupabaseSafetyRepository implements SafetyRepository {
  SupabaseSafetyRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<EmergencyContact>> fetchContacts() async {
    try {
      final rows = await _client
          .from('emergency_contacts')
          .select(EmergencyContact.selectColumns)
          .eq('is_active', true)
          .order('sort_order');
      return [for (final r in rows) EmergencyContact.fromJson(r)];
    } catch (e, s) {
      throw AppException.from(e, s);
    }
  }

  @override
  Future<void> logSos(String studentId, String action) async {
    try {
      await _client.from('sos_events').insert({
        'student_id': studentId,
        'action': action,
      });
    } catch (e, s) {
      throw AppException.from(e, s);
    }
  }
}
