import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/sky_background.dart';
import '../../../auth/presentation/viewModels/auth_provider.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';

/// Profile tab (Figma page 30).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to log in again to use CampusCare.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (ok == true) await auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final student = context.watch<AuthProvider>().student;
    return SkyBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            const PageHeader(actions: [NotificationBell()], showBack: false),
            const SizedBox(height: 16),
            const Text(
              'Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.navy.withAlpha(50),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student?.fullName ?? '',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text('Student No: ${student?.studentNumber ?? ''}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _MenuRow(
                    Icons.person,
                    'Personal Information',
                    () =>
                        Navigator.of(context).push(AppRoutes.profilePersonal()),
                  ),
                  _MenuRow(
                    Icons.assignment,
                    'Intake form',
                    () => Navigator.of(context).push(AppRoutes.profileIntake()),
                  ),
                  _MenuRow(
                    Icons.privacy_tip,
                    'Consent & Privacy',
                    () =>
                        Navigator.of(context).push(AppRoutes.profileConsent()),
                  ),
                  _MenuRow(
                    Icons.local_fire_department,
                    'View Streak',
                    () => Navigator.of(context).push(AppRoutes.streaks()),
                  ),
                  _MenuRow(
                    Icons.settings,
                    'Settings',
                    () =>
                        Navigator.of(context).push(AppRoutes.profileSettings()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const GlassCard(
              padding: EdgeInsets.all(14),
              child: Text(
                'Your information is private and can only be accessed by authorised Wellness Centre staff.',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Log out',
              style: AppButtonStyle.outlined,
              onPressed: () => _confirmLogout(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow(this.icon, this.label, this.onTap);

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Semantics(
        button: true,
        label: label,
        child: ExcludeSemantics(
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(90),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.navy),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
