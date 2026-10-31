import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/onboarding_repository.dart';
import '../../models/academic_info.dart';
import '../../models/next_of_kin.dart';
import '../../models/onboarding_snapshot.dart';
import '../../models/personal_info.dart';
import '../../models/presenting_concern.dart';
import '../../models/referral_source.dart';
import '../../models/residence_info.dart';

enum OnboardingLoad { loading, ready, error }

/// Drives the onboarding wizard. Every "Next" saves to Supabase first and only then
/// advances, so progress is never shown that was not actually stored. Save methods throw
/// [AppException]; the step screens catch it and show the message.
class OnboardingProvider extends ChangeNotifier {
  /// With [editStep] set, the provider runs one step on its own (from the Profile tab):
  /// it opens at that step, saving does not advance, and [saved] becomes true.
  OnboardingProvider(this._repo, this._studentId, {this.editStep});

  final OnboardingRepository _repo;
  final String _studentId;
  final OnboardingStep? editStep;
  bool _saved = false;

  bool get editing => editStep != null;

  /// True once the edited step has been saved (edit mode only).
  bool get saved => _saved;

  OnboardingLoad _load = OnboardingLoad.loading;
  String? _loadError;
  OnboardingSnapshot? _snapshot;
  List<PresentingConcern> _catalog = const [];
  OnboardingStep _step = OnboardingStep.consent;
  bool _disposed = false;

  OnboardingLoad get loadState => _load;
  String? get loadError => _loadError;
  OnboardingSnapshot get snapshot => _snapshot!;
  List<PresentingConcern> get concernCatalog => _catalog;
  OnboardingStep get step => _step;
  int get stepCount => OnboardingStep.values.length;

  Future<void> load() async {
    _load = OnboardingLoad.loading;
    _loadError = null;
    _notify();
    try {
      final results = await Future.wait<Object>([
        _repo.loadSnapshot(_studentId),
        _repo.fetchConcernCatalog(),
      ]);
      _snapshot = results[0] as OnboardingSnapshot;
      _catalog = results[1] as List<PresentingConcern>;
      // Resume where the student stopped, or open the one step being edited.
      _step = editStep ?? _snapshot!.firstIncompleteStep;
      _load = OnboardingLoad.ready;
    } on AppException catch (e) {
      _loadError = e.message;
      _load = OnboardingLoad.error;
    }
    _notify();
  }

  void back() {
    if (editing) return;
    final i = _step.index;
    if (i > 0) _goTo(OnboardingStep.values[i - 1]);
  }

  Future<void> saveConsent() async {
    if (!snapshot.hasActiveConsent) {
      await _repo.recordConsent(_studentId);
      _snapshot = snapshot.copyWith(hasActiveConsent: true);
    }
    _goTo(OnboardingStep.personal);
  }

  Future<void> savePersonal(PersonalInfo info) async {
    await _repo.savePersonal(_studentId, info);
    _snapshot = snapshot.copyWith(personal: info);
    _goTo(OnboardingStep.nextOfKin);
  }

  Future<void> saveNextOfKin(NextOfKin kin) async {
    await _repo.saveNextOfKin(_studentId, kin);
    _snapshot = snapshot.copyWith(nextOfKin: kin);
    _goTo(OnboardingStep.academic);
  }

  Future<void> saveAcademic(AcademicInfo info) async {
    await _repo.saveAcademic(_studentId, info);
    _snapshot = snapshot.copyWith(academic: info);
    _goTo(OnboardingStep.residence);
  }

  Future<void> saveResidence(ResidenceInfo info) async {
    await _repo.saveResidence(_studentId, info);
    _snapshot = snapshot.copyWith(residence: info);
    _goTo(OnboardingStep.concerns);
  }

  Future<void> saveConcerns(Set<String> codes) async {
    await _repo.saveConcerns(codes.toList());
    _snapshot = snapshot.copyWith(concernCodes: codes);
    _goTo(OnboardingStep.referral);
  }

  /// Saves the referral source, then asks the database to finish onboarding.
  /// The caller refreshes the auth state afterwards so the router moves on.
  Future<void> saveReferralAndComplete(ReferralSource source) async {
    await _repo.saveReferral(_studentId, source);
    _snapshot = snapshot.copyWith(referral: source);
    if (editing) {
      _goTo(OnboardingStep.referral);
      return;
    }
    await _repo.completeOnboarding();
  }

  void _goTo(OnboardingStep s) {
    if (editing) {
      _saved = true; // stay on this step; the edit screen closes itself
      _notify();
      return;
    }
    _step = s;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
