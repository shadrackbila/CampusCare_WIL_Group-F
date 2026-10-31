import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../shared/realtime/realtime_handle.dart';
import '../../data/messaging_repository.dart';
import '../../models/chat_message.dart';

/// One open chat: loads the history, listens for new messages live, sends messages.
/// Create it when the chat screen opens and dispose it when the screen closes: disposing
/// closes the realtime channel.
class ChatProvider extends ChangeNotifier {
  ChatProvider(
    this._repo, {
    required this.conversationId,
    required this.myUserId,
  });

  final MessagingRepository _repo;
  final String conversationId;
  final String myUserId;

  List<ChatMessage> _messages = const [];
  RealtimeHandle? _handle;
  bool _loading = false;
  bool _loaded = false;
  bool _sending = false;
  String? _error;
  String? _sendError;
  bool _disposed = false;

  List<ChatMessage> get messages => _messages;
  bool get loading => _loading;
  bool get loaded => _loaded;
  bool get sending => _sending;
  String? get error => _error;
  String? get sendError => _sendError;

  Future<void> start() async {
    _handle = _repo.subscribe(
      conversationId,
      onMessage: _onIncoming,
      // Runs when the live connection is established or restored: catch up on anything missed.
      onReady: () => unawaited(_refresh()),
    );
    await _refresh(showSpinner: true);
  }

  Future<void> _refresh({bool showSpinner = false}) async {
    if (showSpinner) {
      _loading = true;
      _error = null;
      _notify();
    }
    try {
      final fetched = await _repo.fetchMessages(conversationId);
      _merge(fetched);
      _loaded = true;
      _error = null;
      unawaited(_markRead());
    } on AppException catch (e) {
      if (!_loaded) _error = e.message;
    } finally {
      if (showSpinner) _loading = false;
      _notify();
    }
  }

  void _onIncoming(ChatMessage m) {
    if (m.conversationId != conversationId) return;
    _merge([m]);
    _notify();
    if (m.senderId != myUserId) unawaited(_markRead());
  }

  /// Adds messages we do not have yet (by id) and keeps the list in time order.
  void _merge(List<ChatMessage> incoming) {
    final byId = {for (final m in _messages) m.id: m};
    for (final m in incoming) {
      byId[m.id] = m;
    }
    final list = byId.values.toList()
      ..sort((a, b) {
        final c = a.createdAt.compareTo(b.createdAt);
        return c != 0 ? c : a.id.compareTo(b.id);
      });
    _messages = list;
  }

  Future<void> _markRead() async {
    try {
      await _repo.markRead(conversationId, myUserId);
    } on AppException {
      // Not important enough to show; the unread dot just stays until next time.
    }
  }

  /// Returns true when the message was sent (the caller can then clear the text box).
  Future<bool> send(String text) async {
    final body = text.trim();
    if (body.isEmpty || _sending) return false;
    _sending = true;
    _sendError = null;
    _notify();
    try {
      final saved = await _repo.send(conversationId, myUserId, body);
      _merge([saved]);
      return true;
    } on AppException catch (e) {
      _sendError = e.message;
      return false;
    } finally {
      _sending = false;
      _notify();
    }
  }

  Future<void> retry() => _refresh(showSpinner: true);

  void clearSendError() {
    if (_sendError == null) return;
    _sendError = null;
    _notify();
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
