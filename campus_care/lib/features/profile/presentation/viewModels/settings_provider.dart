import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/settings_repository.dart';
import '../../models/user_settings.dart';

/// Notification settings. Changes show immediately and are saved in order; if a save fails the
/// switch goes back to the last saved value and the error is rethrown for the screen to show.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._repo);

  final SettingsRepository _repo;

  String? _userId;
  UserSettings _settings = const UserSettings();
  UserSettings _saved = const UserSettings();
  bool _loading = false;
  bool _loaded = false;
  String? _error;
  int _generation = 0;
  Future<void> _chain = Future.value();
  bool _disposed = false;

  UserSettings get settings => _settings;
  bool get loading => _loading;
  bool get loaded => _loaded;
  String? get error => _error;

  void bind(String? userId) {
    if (userId == _userId) return;
    _userId = userId;
    _generation++;
    _settings = const UserSettings();
    _saved = const UserSettings();
    _loading = false;
    _loaded = false;
    _error = null;
    _chain = Future.value();
  }

  Future<void> load() async {
    final id = _userId;
    if (id == null) return;
    final gen = ++_generation;
    _loading = true;
    _error = null;
    _notify();
    try {
      final s = await _repo.fetch(id);
      if (gen != _generation) return;
      _settings = s;
      _saved = s;
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

  Future<void> update(UserSettings next) {
    final id = _userId;
    if (id == null || next == _settings) return Future.value();
    final gen = _generation;
    _settings = next;
    _notify();
    final done = _chain.then((_) async {
      if (gen != _generation) return;
      final toSave =
          _settings; // the newest choice, in case several taps queued up
      if (toSave == _saved) return;
      try {
        await _repo.save(id, toSave);
        if (gen == _generation) _saved = toSave;
      } on AppException {
        if (gen == _generation) {
          _settings = _saved;
          _notify();
        }
        rethrow;
      }
    });
    _chain = done.catchError((Object _) {});
    return done;
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
