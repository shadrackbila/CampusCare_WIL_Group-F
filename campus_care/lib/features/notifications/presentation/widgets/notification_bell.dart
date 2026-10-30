import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/main_tabs.dart';
import '../viewModels/notification_provider.dart';

/// Bell with an unread badge. Opens the Notifications tab of Messages.
/// Pass it to `PageHeader(actions: [NotificationBell()])` on screens that show it.
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final unread = context.select<NotificationProvider, int>((p) => p.unreadCount);
    return IconButton(
      tooltip: unread > 0 ? 'Notifications, $unread unread' : 'Notifications',
      icon: Badge(
        isLabelVisible: unread > 0,
        label: Text(unread > 9 ? '9+' : '$unread'),
        child: const Icon(Icons.notifications_none, color: Colors.white),
      ),
      onPressed: () => AppNav.toTab(
        context,
        AppTab.messages,
        messages: MessagesTab.notifications,
      ),
    );
  }
}
