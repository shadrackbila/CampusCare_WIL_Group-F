import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../models/academic_info.dart';
import '../models/consent.dart';
import '../models/next_of_kin.dart';
import '../models/onboarding_snapshot.dart';
import '../models/personal_info.dart';
import '../models/presenting_concern.dart';
import '../models/referral_source.dart';
import '../models/residence_info.dart';

/// All onboarding reads/writes. RLS limits every query to the logged-in student's rows.
class OnboardingRepository {
  OnboardingRepository(this._client);

  final SupabaseClient _client;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e, s) {
      throw AppException.from(e, s);
    }
  }

  Future<OnboardingSnapshot> loadSnapshot(String studentId) => _guard(() async {
    final r = await Future.wait<Object?>([
      _client
          .from('students')
          .select(PersonalInfo.selectColumns)
          .eq('id', studentId)
          .single(),
      _client
          .from('next_of_kin')
          .select()
          .eq('student_id', studentId)
          .maybeSingle(),
      _client
          .from('student_academic_info')
          .select()
          .eq('student_id', studentId)
          .maybeSingle(),
      _client
          .from('student_residence')
          .select()
          .eq('student_id', studentId)
          .maybeSingle(),
      _client
          .from('student_concerns')
          .select('presenting_concerns(code)')
          .eq('student_id', studentId),
      _client
          .from('student_intake')
          .select('referral_source')
          .eq('student_id', studentId)
          .maybeSingle(),
      _client
          .from('consent_records')
          .select('id')
          .eq('student_id', studentId)
          .isFilter('withdrawn_at', null)
          .limit(1),
    ]);

    final student = r[0] as Map<String, dynamic>;
    final kin = r[1] as Map<String, dynamic>?;
    final academic = r[2] as Map<String, dynamic>?;
    final residence = r[3] as Map<String, dynamic>?;
    final concerns = (r[4] as List).cast<Map<String, dynamic>>();
    final intake = r[5] as Map<String, dynamic>?;
    final consent = r[6] as List;

    return OnboardingSnapshot(
      personal: PersonalInfo.fromRow(student),
      nextOfKin: kin == null ? null : NextOfKin.fromRow(kin),
      academic: academic == null ? null : AcademicInfo.fromRow(academic),
      residence: residence == null ? null : ResidenceInfo.fromRow(residence),
      concernCodes: {
        for (final c in concerns)
          if (c['presenting_concerns'] != null)
            (c['presenting_concerns'] as Map<String, dynamic>)['code']
                as String,
      },
      referral: ReferralSource.fromCode(intake?['referral_source'] as String?),
      hasActiveConsent: consent.isNotEmpty,
    );
  });

  Future<List<PresentingConcern>> fetchConcernCatalog() => _guard(() async {
    final rows = await _client
        .from('presenting_concerns')
        .select('id, code, label, is_high_risk')
        .eq('is_active', true)
        .order('sort_order');
    return rows.map(PresentingConcern.fromRow).toList();
  });

  Future<void> recordConsent(String studentId) => _guard(() async {
    await _client.from('consent_records').insert({
      'student_id': studentId,
      'consent_version': Consent.version,
      'statements_accepted': Consent.acceptedCodes,
    });
  });

  /// Withdrawing stamps the active record; the history is kept.
  Future<void> withdrawConsent(String studentId) => _guard(() async {
    await _client
        .from('consent_records')
        .update({'withdrawn_at': DateTime.now().toUtc().toIso8601String()})
        .eq('student_id', studentId)
        .isFilter('withdrawn_at', null);
  });

  Future<void> savePersonal(String studentId, PersonalInfo info) =>
      _guard(() async {
        await _client
            .from('students')
            .update(info.toUpdate())
            .eq('id', studentId);
      });

  Future<void> saveNextOfKin(String studentId, NextOfKin kin) =>
      _guard(() async {
        await _client
            .from('next_of_kin')
            .upsert(kin.toUpsert(studentId), onConflict: 'student_id');
      });

  Future<void> saveAcademic(String studentId, AcademicInfo info) =>
      _guard(() async {
        await _client
            .from('student_academic_info')
            .upsert(info.toUpsert(studentId), onConflict: 'student_id');
      });

  Future<void> saveResidence(String studentId, ResidenceInfo info) =>
      _guard(() async {
        await _client
            .from('student_residence')
            .upsert(info.toUpsert(studentId), onConflict: 'student_id');
      });

  Future<void> saveConcerns(List<String> codes) => _guard(() async {
    await _client.rpc('save_my_concerns', params: {'p_codes': codes});
  });

  Future<void> saveReferral(String studentId, ReferralSource source) =>
      _guard(() async {
        await _client.from('student_intake').upsert({
          'student_id': studentId,
          'referral_source': source.code,
        }, onConflict: 'student_id');
      });

  /// The database re-checks that every required section exists before it marks
  /// onboarding as completed.
  Future<void> completeOnboarding() => _guard(() async {
    await _client.rpc('complete_onboarding');
  });
}
