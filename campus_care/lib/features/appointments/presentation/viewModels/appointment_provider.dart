import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/sa_time.dart';
import '../../data/appointment_repository.dart';
import '../../models/appointment.dart';

/// The student's appointment lists and the cancel / confirm actions.
/// Bound to the logged-in student by the app-level proxy provider.
class AppointmentProvider extends ChangeNotifier {
  AppointmentProvider(this._repo, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppointmentRepository _repo;
  final DateTime Function() _clock;

  String? _studentId;
  List<Appointment> _all = const [];
  bool _loading = false;
  bool _loaded = false;
  String? _error;
  final Set<String> _busy = {};
  int _generation = 0;
  bool _disposed = false;

  bool get loading => _loading;
  bool get loaded => _loaded;
  String? get error => _error;
  bool isBusy(String id) => _busy.contains(id);
  DateTime get nowSa => saWallClock(_clock());

  void bind(String? studentId) {
    if (studentId == _studentId) return;
    _studentId = studentId;
    _generation++;
    _all = const [];
    _loading = false;
    _loaded = false;
    _error = null;
    _busy.clear();
  }

  /// Soonest first for upcoming; most recent first for the other lists.
  List<Appointment> forTab(AppointmentTab tab) {
    final now = nowSa;
    final list = _all.where((a) => a.tab(now) == tab).toList();
    list.sort(
      (a, b) => tab == AppointmentTab.upcoming
          ? a.startsAt.compareTo(b.startsAt)
          : b.startsAt.compareTo(a.startsAt),
    );
    return list;
  }

  int count(AppointmentTab tab) => forTab(tab).length;

  Future<void> load({bool silent = false}) async {
    final id = _studentId;
    if (id == null) return;
    final gen = ++_generation;
    if (!silent) {
      _loading = true;
      _error = null;
      _notify();
    }
    try {
      final rows = await _repo.fetchMine(id);
      if (gen != _generation) return;
      _all = rows;
      _loaded = true;
      _error = null;
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

  Future<void> cancel(String appointmentId) =>
      _act(appointmentId, () => _repo.cancel(appointmentId));

  Future<void> confirm(String appointmentId) =>
      _act(appointmentId, () => _repo.confirm(appointmentId));

  Future<void> _act(String id, Future<void> Function() action) async {
    if (_busy.contains(id)) return;
    _busy.add(id);
    _notify();
    try {
      await action();
    } finally {
      _busy.remove(id);
      _notify();
    }
    // The database already changed, so a failed refresh must not look like a failed action.
    unawaited(load(silent: true));
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
