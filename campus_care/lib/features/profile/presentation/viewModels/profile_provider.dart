import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../onboarding/models/onboarding_snapshot.dart';
import '../../../onboarding/models/presenting_concern.dart';
import '../../data/profile_repository.dart';
import '../../models/consent_status.dart';

/// Read-only view of what the student gave during onboarding, plus consent withdrawal.
class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._repo);

  final ProfileRepository _repo;

  String? _studentId;
  OnboardingSnapshot? _snapshot;
  List<PresentingConcern> _catalog = const [];
  ConsentStatus? _consent;
  bool _loading = false;
  bool _loaded = false;
  bool _withdrawing = false;
  String? _error;
  int _generation = 0;
  bool _disposed = false;

  OnboardingSnapshot? get snapshot => _snapshot;
  ConsentStatus? get consent => _consent;
  bool get loading => _loading;
  bool get loaded => _loaded;
  bool get withdrawing => _withdrawing;
  String? get error => _error;

  /// Labels of the concerns the student ticked, in the catalog's order.
  List<String> get concernLabels => [
    for (final c in _catalog)
      if (_snapshot?.concernCodes.contains(c.code) ?? false) c.label,
  ];

  void bind(String? studentId) {
    if (studentId == _studentId) return;
    _studentId = studentId;
    _generation++;
    _snapshot = null;
    _catalog = const [];
    _consent = null;
    _loading = false;
    _loaded = false;
    _withdrawing = false;
    _error = null;
  }

  Future<void> load() async {
    final id = _studentId;
    if (id == null) return;
    final gen = ++_generation;
    _loading = true;
    _error = null;
    _notify();
    try {
      final r = await Future.wait<Object?>([
        _repo.loadSnapshot(id),
        _repo.fetchConcernCatalog(),
        _repo.fetchConsent(id),
      ]);
      if (gen != _generation) return;
      _snapshot = r[0] as OnboardingSnapshot;
      _catalog = r[1] as List<PresentingConcern>;
      _consent = r[2] as ConsentStatus?;
      _loaded = true;
    } on AppException catch (e) {
      if (gen != _generation) return;
      _error = e.message;
    } finally {
      if (gen == _generation) {
        _loading = false;
        _notify();
      }
    }
  }

  /// Throws [AppException] on failure. On success the caller refreshes the auth state so the
  /// router sends the student back to the consent step.
  Future<void> withdrawConsent() async {
    if (_withdrawing) return;
    _withdrawing = true;
    _notify();
    try {
      await _repo.withdrawConsent();
      _consent = null;
      _loaded = false;
    } finally {
      _withdrawing = false;
      _notify();
    }
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
