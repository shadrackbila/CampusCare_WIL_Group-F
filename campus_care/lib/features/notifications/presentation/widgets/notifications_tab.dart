import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/routing/main_tabs.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/time_label.dart';
import '../../../../shared/widgets/error_banner.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../models/app_notification.dart';
import '../viewModels/notification_provider.dart';

/// The notifications list shown in the Notifications tab of the Messages screen.
class NotificationsTab extends StatelessWidget {
  const NotificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final n = context.watch<NotificationProvider>();
    final now = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (n.unreadCount > 0)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _run(
                context,
                () => context.read<NotificationProvider>().markAllRead(),
              ),
              child: const Text(
                'Mark all as read',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        if (n.error != null) ...[
          ErrorBanner(n.error!),
          TextButton(
            onPressed: () => context.read<NotificationProvider>().load(),
            child: const Text(
              'Try again',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        if (n.loading && !n.loaded)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          )
        else if (n.items.isEmpty && n.error == null)
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              'No notifications yet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          )
        else
          for (final item in n.items)
            _NotificationTile(
              item: item,
              now: now,
              onTap: () async {
                final ctx = context;
                await _run(
                  context,
                  () => context.read<NotificationProvider>().markRead(item.id),
                );
                if (item.isAppointmentRelated && ctx.mounted) {
                  AppNav.toTab(ctx, AppTab.appointments);
                }
              },
            ),
      ],
    );
  }

  static Future<void> _run(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
    } on AppException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.now,
    required this.onTap,
  });

  final AppNotification item;
  final DateTime now;
  final VoidCallback onTap;

  IconData get _icon {
    if (item.isAlert) return Icons.priority_high;
    if (item.isAppointmentRelated) return Icons.calendar_month;
    if (item.type == 'streak_update') return Icons.local_fire_department;
    return Icons.info_outline;
  }

  @override
  Widget build(BuildContext context) {
    final time = listTimeLabel(item.createdAt, now);
    final color = item.isAlert ? AppColors.error : AppColors.blue;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        button: true,
        label:
            '${item.title}. ${item.body} $time${item.read ? '' : ', unread'}',
        child: ExcludeSemantics(
          child: InkWell(
            borderRadius: BorderRadius.circular(32),
            onTap: onTap,
            child: GlassCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(_icon, color: color, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: item.read
                                ? FontWeight.w600
                                : FontWeight.w800,
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(item.body),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(time, style: const TextStyle(fontSize: 12)),
                      if (!item.read)
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
