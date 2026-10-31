import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../shared/realtime/realtime_handle.dart';
import '../../data/notification_repository.dart';
import '../../models/app_notification.dart';

/// The student's notifications, kept live while they are logged in. The realtime
/// subscription is opened when a user is bound and closed when they log out or the
/// provider is disposed.
class NotificationProvider extends ChangeNotifier {
  NotificationProvider(this._repo);

  final NotificationRepository _repo;

  String? _userId;
  List<AppNotification> _items = const [];
  RealtimeHandle? _handle;
  bool _loading = false;
  bool _loaded = false;
  String? _error;
  int _generation = 0;
  bool _disposed = false;

  List<AppNotification> get items => _items;
  bool get loading => _loading;
  bool get loaded => _loaded;
  String? get error => _error;
  int get unreadCount => _items.where((n) => !n.read).length;

  /// Called by the proxy provider (during build, so it never notifies synchronously).
  void bind(String? userId) {
    if (userId == _userId) return;
    _userId = userId;
    _generation++;
    unawaited(_handle?.close());
    _handle = null;
    _items = const [];
    _loading = false;
    _loaded = false;
    _error = null;
    if (userId != null) unawaited(_start(userId, _generation));
  }

  Future<void> _start(String userId, int gen) async {
    await load();
    if (gen != _generation || _disposed) return;
    _handle = _repo.subscribe(userId, () => unawaited(load(silent: true)));
  }

  Future<void> load({bool silent = false}) async {
    if (_userId == null) return;
    final gen = _generation;
    if (!silent) {
      _loading = true;
      _error = null;
      _notify();
    }
    try {
      final rows = await _repo.fetch();
      if (gen != _generation) return;
      _items = rows;
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

  /// Marks one notification read straight away on screen, then saves it.
  Future<void> markRead(String id) async {
    final i = _items.indexWhere((n) => n.id == id);
    if (i < 0 || _items[i].read) return;
    final before = _items;
    _items = [for (final n in _items) n.id == id ? n.copyWith(read: true) : n];
    _notify();
    try {
      await _repo.markRead(id);
    } on AppException {
      _items = before; // roll back so the badge stays truthful
      _notify();
      rethrow;
    }
  }

  Future<void> markAllRead() async {
    if (unreadCount == 0) return;
    final before = _items;
    _items = [for (final n in _items) n.copyWith(read: true)];
    _notify();
    try {
      await _repo.markAllRead();
    } on AppException {
      _items = before;
      _notify();
      rethrow;
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_handle?.close());
    _handle = null;
    super.dispose();
  }
}
