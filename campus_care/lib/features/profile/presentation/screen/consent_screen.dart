import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/sa_time.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../auth/presentation/viewModels/auth_provider.dart';
import '../../../onboarding/models/consent.dart';
import '../viewModels/profile_provider.dart';
import '../widgets/profile_scaffold.dart';

class ConsentScreen extends StatelessWidget {
  const ConsentScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      ProfilePage(title: 'Consent & Privacy', builder: _sections);

  static Future<void> _withdraw(BuildContext context) async {
    final profile = context.read<ProfileProvider>();
    final auth = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Withdraw consent?'),
        content: const Text(
          'You will need to agree again before you can keep using CampusCare. '
          'The information you have already given is not deleted. '
          'To have it removed, please contact the Wellness Centre.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep my consent'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await profile.withdrawConsent();
      // Reloads the student: with onboarding reopened, the router sends them to the consent step.
      await auth.refreshStudent();
    } on AppException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  static List<Widget> _sections(BuildContext context, ProfileProvider p) {
    final c = p.consent;
    final when = c == null ? null : formatDate(saWallClock(c.acceptedAt));
    return [
      Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(215),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You agreed to:',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 8),
            for (final s in Consent.statements)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(s.text)),
                  ],
                ),
              ),
          ],
        ),
      ),
      DetailSection(
        title: 'Your consent record',
        rows: [
          (
            'Status',
            c == null
                ? 'No consent on file'
                : (c.isActive ? 'Active' : 'Withdrawn'),
          ),
          ('Agreed on', when),
          ('Version', c?.version),
        ],
      ),
      if (c != null && c.isActive)
        AppButton(
          label: 'Withdraw consent',
          style: AppButtonStyle.outlined,
          loading: p.withdrawing,
          onPressed: () => _withdraw(context),
        ),
    ];
  }
}
