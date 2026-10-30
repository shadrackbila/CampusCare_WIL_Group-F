import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/error_banner.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/sky_background.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../../models/user_settings.dart';
import '../viewModels/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<SettingsProvider>().load();
    });
  }

  Future<void> _change(UserSettings next) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<SettingsProvider>().update(next);
    } on AppException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SettingsProvider>();
    final s = p.settings;
    final master = s.notificationsEnabled;
    return SkyBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            const PageHeader(actions: [NotificationBell()]),
            const SizedBox(height: 16),
            const Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            if (p.error != null) ...[
              ErrorBanner(p.error!),
              TextButton(
                onPressed: () => context.read<SettingsProvider>().load(),
                child: const Text(
                  'Try again',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
            if (p.loading && !p.loaded)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            else if (p.loaded) ...[
              GlassCard(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text(
                        'Notifications',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: const Text('Turn all notifications on or off'),
                      value: master,
                      onChanged: (v) =>
                          _change(s.copyWith(notificationsEnabled: v)),
                    ),
                    SwitchListTile(
                      title: const Text('Appointment reminders'),
                      value: s.appointmentReminders,
                      onChanged: master
                          ? (v) => _change(s.copyWith(appointmentReminders: v))
                          : null,
                    ),
                    SwitchListTile(
                      title: const Text('Streak updates'),
                      value: s.streakNotifications,
                      onChanged: master
                          ? (v) => _change(s.copyWith(streakNotifications: v))
                          : null,
                    ),
                    SwitchListTile(
                      title: const Text('Wellness tips'),
                      value: s.wellnessTips,
                      onChanged: master
                          ? (v) => _change(s.copyWith(wellnessTips: v))
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(8),
                child: ListTile(
                  leading: const Icon(
                    Icons.lock_outline,
                    color: AppColors.navy,
                  ),
                  title: const Text(
                    'Change password',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      Navigator.of(context).push(AppRoutes.profilePassword()),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
