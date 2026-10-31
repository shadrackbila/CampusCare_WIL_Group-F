import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/messaging_repository.dart';
import '../../models/conversation_summary.dart';

/// The list of chats and the "Let's Chat" action. Bound to the logged-in user.
class MessagingProvider extends ChangeNotifier {
  MessagingProvider(this._repo);

  final MessagingRepository _repo;

  String? _userId;
  List<ConversationSummary> _conversations = const [];
  bool _loading = false;
  bool _loaded = false;
  bool _opening = false;
  String? _error;
  int _generation = 0;
  bool _disposed = false;

  List<ConversationSummary> get conversations => _conversations;
  bool get loading => _loading;
  bool get loaded => _loaded;
  bool get opening => _opening;
  String? get error => _error;
  bool get hasUnread => _conversations.any((c) => c.unread);

  ConversationSummary? byId(String id) {
    for (final c in _conversations) {
      if (c.id == id) return c;
    }
    return null;
  }

  void bind(String? userId) {
    if (userId == _userId) return;
    _userId = userId;
    _generation++;
    _conversations = const [];
    _loading = false;
    _loaded = false;
    _opening = false;
    _error = null;
  }

  Future<void> load({bool silent = false}) async {
    final id = _userId;
    if (id == null) return;
    final gen = ++_generation;
    if (!silent) {
      _loading = true;
      _error = null;
      _notify();
    }
    try {
      final rows = await _repo.fetchConversations(id);
      if (gen != _generation) return;
      _conversations = rows;
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

  /// Opens the student's peer-educator chat, creating it the first time.
  /// Returns the conversation id. Throws [AppException] (e.g. no peer educator available).
  Future<String> openPeerChat() async {
    if (_opening) {
      throw const AppException('Opening your chat, please wait a moment.');
    }
    _opening = true;
    _notify();
    try {
      final id = await _repo.startPeerChat();
      await load(
        silent: true,
      ); // so the chat screen can show the other person's name
      return id;
    } finally {
      _opening = false;
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
