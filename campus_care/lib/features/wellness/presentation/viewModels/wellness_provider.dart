import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/sa_time.dart';
import '../../data/wellness_repository.dart';
import '../../models/mood_entry.dart';
import '../../models/streaks.dart';
import '../../models/weekly_mood.dart';

/// Home / streaks data and the two check-in actions. Bound to the logged-in student by
/// the app-level proxy provider; switching student (or logging out) clears everything.
class WellnessProvider extends ChangeNotifier {
  WellnessProvider(this._repo, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final WellnessRepository _repo;
  final DateTime Function() _clock;

  String? _studentId;
  Streaks _streaks = Streaks.empty;
  MoodEntry? _todayMood;
  List<WeeklyMood> _weekly = const [];
  bool _loading = false;
  bool _loaded = false;
  bool _saving = false;
  String? _error;
  int _generation = 0;
  bool _disposed = false;

  Streaks get streaks => _streaks;
  MoodEntry? get todayMood => _todayMood;
  bool get loading => _loading;
  bool get loaded => _loaded;
  bool get saving => _saving;
  String? get error => _error;

  DateTime get _today => saToday(_clock());
  int get checkinStreak => _streaks.checkinStreak(_today);
  int get loginStreak => _streaks.loginStreak(_today);
  List<WeeklyMood> get fourWeeks => WeeklyMood.lastFourWeeks(_weekly, _today);

  /// Called by the proxy provider. Does not notify (it runs during build).
  void bind(String? studentId) {
    if (studentId == _studentId) return;
    _studentId = studentId;
    _generation++;
    _streaks = Streaks.empty;
    _todayMood = null;
    _weekly = const [];
    _loading = false;
    _loaded = false;
    _saving = false;
    _error = null;
  }

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
      final r = await Future.wait<Object?>([
        _repo.fetchStreaks(id),
        _repo.fetchLatestMoodSince(id, startOfSaDayUtc(_clock())),
        _repo.fetchWeekly(id),
      ]);
      if (gen != _generation) return;
      _streaks = r[0] as Streaks;
      _todayMood = r[1] as MoodEntry?;
      _weekly = r[2] as List<WeeklyMood>;
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

  /// Saves a mood check-in. The database trigger updates the streak.
  Future<MoodEntry> submitMood(int score) async {
    final id = _requireStudent();
    _startSaving();
    try {
      final entry = await _repo.saveMood(studentId: id, score: score);
      _todayMood = entry;
      unawaited(load(silent: true)); // pick up the new streak and graph
      return entry;
    } finally {
      _saving = false;
      _notify();
    }
  }

  Future<void> submitEmotional({
    required int stress,
    required int coping,
    required int support,
    String? moodEntryId,
  }) async {
    final id = _requireStudent();
    _startSaving();
    try {
      await _repo.saveEmotional(
        studentId: id,
        stress: stress,
        coping: coping,
        support: support,
        moodEntryId: moodEntryId,
      );
    } finally {
      _saving = false;
      _notify();
    }
  }

  String _requireStudent() {
    final id = _studentId;
    if (id == null) {
      throw const AppException('Please log in again.', type: AppErrorType.auth);
    }
    return id;
  }

  void _startSaving() {
    if (_saving) {
      throw const AppException('Still saving, please wait a moment.');
    }
    _saving = true;
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
