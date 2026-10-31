import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/journal_repository.dart';
import '../../models/journal_entry.dart';

/// The student's journal. Bound to the logged-in student by the app-level proxy provider.
class JournalProvider extends ChangeNotifier {
  JournalProvider(this._repo);

  final JournalRepository _repo;

  String? _studentId;
  List<JournalEntry> _entries = const [];
  bool _loading = false;
  bool _loaded = false;
  bool _saving = false;
  String? _error;
  int _generation = 0;
  bool _disposed = false;

  List<JournalEntry> get entries => _entries;
  bool get loading => _loading;
  bool get loaded => _loaded;
  bool get saving => _saving;
  String? get error => _error;

  JournalEntry? byId(String id) {
    for (final e in _entries) {
      if (e.id == id) return e;
    }
    return null;
  }

  void bind(String? studentId) {
    if (studentId == _studentId) return;
    _studentId = studentId;
    _generation++;
    _entries = const [];
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
      final rows = await _repo.fetch(id);
      if (gen != _generation) return;
      _entries = rows;
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

  Future<JournalEntry> add({
    required String content,
    int? moodScore,
    List<String> tags = const [],
  }) async {
    final id = _studentId;
    if (id == null) {
      throw const AppException('Please log in again.', type: AppErrorType.auth);
    }
    if (_saving) {
      throw const AppException('Still saving, please wait a moment.');
    }
    _saving = true;
    _notify();
    try {
      final entry = await _repo.add(
        studentId: id,
        content: content,
        moodScore: moodScore,
        tags: tags,
      );
      _entries = [entry, ..._entries];
      return entry;
    } finally {
      _saving = false;
      _notify();
    }
  }

  Future<void> delete(String entryId) async {
    await _repo.delete(entryId);
    _entries = _entries.where((e) => e.id != entryId).toList();
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
