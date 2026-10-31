import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../../../shared/realtime/realtime_handle.dart';
import '../models/chat_message.dart';
import '../models/conversation_summary.dart';

abstract class MessagingRepository {
  /// Opens (or reuses) the student's peer-educator chat. Returns the conversation id.
  Future<String> startPeerChat();
  Future<List<ConversationSummary>> fetchConversations(String userId);
  Future<List<ChatMessage>> fetchMessages(String conversationId);
  Future<ChatMessage> send(String conversationId, String senderId, String body);
  Future<void> markRead(String conversationId, String userId);

  /// [onReady] fires each time the live connection is (re)established, so the caller can
  /// re-fetch anything it may have missed.
  RealtimeHandle subscribe(
    String conversationId, {
    required void Function(ChatMessage) onMessage,
    required void Function() onReady,
  });
}

class SupabaseMessagingRepository implements MessagingRepository {
  SupabaseMessagingRepository(this._client);

  final SupabaseClient _client;

  static const maxLength = 1000;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e, s) {
      throw AppException.from(e, s);
    }
  }

  @override
  Future<String> startPeerChat() => _guard(() async {
    final res = await _client.rpc('start_peer_chat');
    return res as String;
  });

  @override
  Future<List<ConversationSummary>> fetchConversations(String userId) => _guard(
    () async {
      final convs = await _client
          .from('conversations')
          .select('id, kind, last_message_at')
          .order('last_message_at', ascending: false);
      if (convs.isEmpty) return <ConversationSummary>[];

      final ids = [for (final c in convs) c['id'] as String];
      final parts = await _client
          .from('conversation_participants')
          .select('conversation_id, user_id, last_read_at')
          .inFilter('conversation_id', ids);

      final otherUserIds = <String>{
        for (final p in parts)
          if (p['user_id'] != userId) p['user_id'] as String,
      }.toList();

      final peers = otherUserIds.isEmpty
          ? <Map<String, dynamic>>[]
          : await _client
                .from('peer_educators')
                .select('user_id, full_name, photo_url')
                .inFilter('user_id', otherUserIds);
      final pracs = otherUserIds.isEmpty
          ? <Map<String, dynamic>>[]
          : await _client
                .from('practitioners')
                .select('user_id, full_name, title, photo_url')
                .inFilter('user_id', otherUserIds);

      final names = <String, ({String name, String role, String? photo})>{};
      for (final p in peers) {
        names[p['user_id'] as String] = (
          name: p['full_name'] as String,
          role: 'Peer Educator',
          photo: p['photo_url'] as String?,
        );
      }
      for (final p in pracs) {
        final title = (p['title'] as String?)?.trim() ?? '';
        final n = p['full_name'] as String;
        names[p['user_id'] as String] = (
          name: title.isEmpty ? n : '$title $n',
          role: 'Practitioner',
          photo: p['photo_url'] as String?,
        );
      }

      final lastRows = await Future.wait([
        for (final id in ids)
          _client
              .from('messages')
              .select('sender_id, body, created_at')
              .eq('conversation_id', id)
              .order('created_at', ascending: false)
              .limit(1),
      ]);

      final out = <ConversationSummary>[];
      for (var i = 0; i < convs.length; i++) {
        final id = ids[i];
        final mine = parts.where(
          (p) => p['conversation_id'] == id && p['user_id'] == userId,
        );
        final myRead = mine.isEmpty || mine.first['last_read_at'] == null
            ? null
            : DateTime.parse(mine.first['last_read_at'] as String);
        final otherId = parts
            .where((p) => p['conversation_id'] == id && p['user_id'] != userId)
            .map((p) => p['user_id'] as String)
            .firstOrNull;
        final who = otherId == null ? null : names[otherId];
        final last = lastRows[i].isEmpty ? null : lastRows[i].first;
        final lastAt = last == null
            ? null
            : DateTime.parse(last['created_at'] as String);
        final fromOther = last != null && last['sender_id'] != userId;
        out.add(
          ConversationSummary(
            id: id,
            kind: convs[i]['kind'] as String,
            otherName: who?.name ?? 'Peer Educator',
            otherRole: who?.role ?? 'Peer Educator',
            photoUrl: who?.photo,
            lastBody: last?['body'] as String?,
            lastAt: lastAt,
            unread:
                fromOther &&
                lastAt != null &&
                (myRead == null || lastAt.isAfter(myRead)),
          ),
        );
      }
      return out;
    },
  );

  @override
  Future<List<ChatMessage>> fetchMessages(String conversationId) =>
      _guard(() async {
        final rows = await _client
            .from('messages')
            .select(ChatMessage.selectColumns)
            .eq('conversation_id', conversationId)
            .order('created_at', ascending: false)
            .limit(300);
        return [for (final r in rows.reversed) ChatMessage.fromJson(r)];
      });

  @override
  Future<ChatMessage> send(
    String conversationId,
    String senderId,
    String body,
  ) => _guard(() async {
    final text = body.trim();
    if (text.isEmpty) {
      throw const AppException(
        'Please type a message first.',
        type: AppErrorType.validation,
      );
    }
    if (text.length > maxLength) {
      throw const AppException(
        'That message is too long. Please shorten it.',
        type: AppErrorType.validation,
      );
    }
    final row = await _client
        .from('messages')
        .insert({
          'conversation_id': conversationId,
          'sender_id': senderId,
          'body': text,
        })
        .select(ChatMessage.selectColumns)
        .single();
    return ChatMessage.fromJson(row);
  });

  @override
  Future<void> markRead(String conversationId, String userId) =>
      _guard(() async {
        await _client
            .from('conversation_participants')
            .update({'last_read_at': DateTime.now().toUtc().toIso8601String()})
            .eq('conversation_id', conversationId)
            .eq('user_id', userId);
      });

  @override
  RealtimeHandle subscribe(
    String conversationId, {
    required void Function(ChatMessage) onMessage,
    required void Function() onReady,
  }) {
    final channel = _client
        .channel('chat:$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) {
            try {
              onMessage(ChatMessage.fromJson(payload.newRecord));
            } catch (_) {
              // A malformed event is ignored; the next re-fetch picks the message up.
            }
          },
        )
        .subscribe((status, _) {
          if (status == RealtimeSubscribeStatus.subscribed) onReady();
        });
    return CallbackRealtimeHandle(() async {
      await _client.removeChannel(channel);
    });
  }
}
