import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../../../shared/realtime/realtime_handle.dart';
import '../models/app_notification.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> fetch();
  Future<void> markRead(String id);
  Future<void> markAllRead();

  /// Calls [onChange] whenever one of this user's notifications is added or changed.
  RealtimeHandle subscribe(String userId, void Function() onChange);
}

class SupabaseNotificationRepository implements NotificationRepository {
  SupabaseNotificationRepository(this._client);

  final SupabaseClient _client;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e, s) {
      throw AppException.from(e, s);
    }
  }

  // RLS limits every query here to the logged-in user's own notifications.
  @override
  Future<List<AppNotification>> fetch() => _guard(() async {
    final rows = await _client
        .from('notifications')
        .select(AppNotification.selectColumns)
        .order('created_at', ascending: false)
        .limit(100);
    return [for (final r in rows) AppNotification.fromJson(r)];
  });

  @override
  Future<void> markRead(String id) => _guard(() async {
    await _client.from('notifications').update({'read': true}).eq('id', id);
  });

  @override
  Future<void> markAllRead() => _guard(() async {
    await _client
        .from('notifications')
        .update({'read': true})
        .eq('read', false);
  });

  @override
  RealtimeHandle subscribe(String userId, void Function() onChange) {
    final channel = _client
        .channel('notifications:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (_) => onChange(),
        )
        .subscribe();
    return CallbackRealtimeHandle(() async {
      await _client.removeChannel(channel);
    });
  }
}
