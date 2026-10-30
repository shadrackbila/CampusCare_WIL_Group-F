import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/routing/main_tabs.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/time_label.dart';
import '../../../../shared/widgets/error_banner.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/practitioner_avatar.dart';
import '../../../../shared/widgets/sky_background.dart';
import '../../../notifications/presentation/viewModels/notification_provider.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../../../notifications/presentation/widgets/notifications_tab.dart';
import '../../models/conversation_summary.dart';
import '../open_peer_chat.dart';
import '../viewModels/messaging_provider.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key, this.initialTab = MessagesTab.chats});

  final MessagesTab initialTab;

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late MessagesTab _tab = widget.initialTab;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final m = context.read<MessagingProvider>();
      m.load(silent: m.loaded);
      final n = context.read<NotificationProvider>();
      n.load(silent: n.loaded);
    });
  }

  @override
  void didUpdateWidget(MessagesScreen old) {
    super.didUpdateWidget(old);
    if (old.initialTab != widget.initialTab) _tab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final unread = context.select<NotificationProvider, int>(
      (p) => p.unreadCount,
    );
    return SkyBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            const PageHeader(actions: [NotificationBell()], showBack: false),
            const SizedBox(height: 16),
            const Text(
              'Messages',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _Pill(
                  label: 'Chats',
                  selected: _tab == MessagesTab.chats,
                  onTap: () => setState(() => _tab = MessagesTab.chats),
                ),
                const SizedBox(width: 8),
                _Pill(
                  label: 'Notifications',
                  badge: unread,
                  selected: _tab == MessagesTab.notifications,
                  onTap: () => setState(() => _tab = MessagesTab.notifications),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_tab == MessagesTab.chats)
              _ChatsTab(
                onShowNotifications: () =>
                    setState(() => _tab = MessagesTab.notifications),
              )
            else
              const NotificationsTab(),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge = 0,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: badge > 0 ? '$label, $badge unread' : label,
      child: ExcludeSemantics(
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.white24,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected ? AppColors.navy : Colors.white,
                  ),
                ),
                if (badge > 0) ...[
                  const SizedBox(width: 6),
                  Badge(label: Text(badge > 9 ? '9+' : '$badge')),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatsTab extends StatelessWidget {
  const _ChatsTab({required this.onShowNotifications});

  final VoidCallback onShowNotifications;

  @override
  Widget build(BuildContext context) {
    final m = context.watch<MessagingProvider>();
    final now = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ActionTile(
          icon: Icons.chat_bubble,
          title: "Let's Chat",
          subtitle: 'Peer Educator Chat',
          busy: m.opening,
          onTap: m.opening ? null : () => openPeerChat(context),
        ),
        const SizedBox(height: 12),
        _ActionTile(
          icon: Icons.notifications,
          title: 'Messages & Reminders',
          subtitle: 'Appointments, streaks and tips',
          onTap: onShowNotifications,
        ),
        const SizedBox(height: 16),
        if (m.error != null) ...[
          ErrorBanner(m.error!),
          TextButton(
            onPressed: () => context.read<MessagingProvider>().load(),
            child: const Text(
              'Try again',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        if (m.loading && !m.loaded)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          )
        else if (m.conversations.isEmpty && m.error == null)
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              'No chats yet. Tap "Let\'s Chat" to talk to a peer educator.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          )
        else
          for (final c in m.conversations) _ConversationTile(c: c, now: now),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.busy = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title. $subtitle',
      child: ExcludeSemantics(
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: onTap,
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.blue, size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      Text(subtitle),
                    ],
                  ),
                ),
                if (busy)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.c, required this.now});

  final ConversationSummary c;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final time = c.lastAt == null ? '' : listTimeLabel(c.lastAt!, now);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        button: true,
        label:
            '${c.otherName}, ${c.otherRole}. ${c.lastBody ?? ''} $time${c.unread ? ', unread' : ''}',
        child: ExcludeSemantics(
          child: InkWell(
            borderRadius: BorderRadius.circular(32),
            onTap: () => Navigator.of(context).push(AppRoutes.chat(c.id)),
            child: GlassCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  PractitionerAvatar(
                    photoUrl: c.photoUrl,
                    seed: c.id,
                    size: 48,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.otherName,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(c.otherRole, style: const TextStyle(fontSize: 12)),
                        if (c.lastBody != null)
                          Text(
                            c.lastBody!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: c.unread
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(time, style: const TextStyle(fontSize: 12)),
                      if (c.unread)
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
