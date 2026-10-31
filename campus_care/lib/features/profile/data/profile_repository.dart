import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../../onboarding/data/onboarding_repository.dart';
import '../../onboarding/models/onboarding_snapshot.dart';
import '../../onboarding/models/presenting_concern.dart';
import '../models/consent_status.dart';

abstract class ProfileRepository {
  Future<OnboardingSnapshot> loadSnapshot(String studentId);
  Future<List<PresentingConcern>> fetchConcernCatalog();

  /// The most recent consent record, or null if there is none.
  Future<ConsentStatus?> fetchConsent(String studentId);

  /// Stamps the active consent as withdrawn and reopens onboarding (server-side function).
  Future<void> withdrawConsent();
}

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._client, this._onboarding);

  final SupabaseClient _client;
  final OnboardingRepository _onboarding;

  @override
  Future<OnboardingSnapshot> loadSnapshot(String studentId) =>
      _onboarding.loadSnapshot(studentId);

  @override
  Future<List<PresentingConcern>> fetchConcernCatalog() =>
      _onboarding.fetchConcernCatalog();

  @override
  Future<ConsentStatus?> fetchConsent(String studentId) async {
    try {
      final rows = await _client
          .from('consent_records')
          .select(ConsentStatus.selectColumns)
          .eq('student_id', studentId)
          .order('accepted_at', ascending: false)
          .limit(1);
      return rows.isEmpty ? null : ConsentStatus.fromJson(rows.first);
    } catch (e, s) {
      throw AppException.from(e, s);
    }
  }

  @override
  Future<void> withdrawConsent() async {
    try {
      await _client.rpc('withdraw_my_consent');
    } catch (e, s) {
      throw AppException.from(e, s);
    }
  }
}
