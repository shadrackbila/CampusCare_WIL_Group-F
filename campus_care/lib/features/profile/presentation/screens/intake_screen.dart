import 'package:flutter/material.dart';

import '../../../../core/routing/app_router.dart';
import '../../../onboarding/models/onboarding_snapshot.dart';
import '../viewModels/profile_provider.dart';
import '../widgets/profile_scaffold.dart';

/// The intake answers: presenting concerns and who referred the student (read-only).
class IntakeScreen extends StatelessWidget {
  const IntakeScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      ProfilePage(title: 'Intake form', builder: _sections);

  static List<Widget> _sections(BuildContext context, ProfileProvider p) {
    final concerns = p.concernLabels;
    return [
      DetailSection(
        title: 'Presenting concerns',
        onEdit: () => Navigator.of(
          context,
        ).push(AppRoutes.profileEdit(OnboardingStep.concerns)),
        rows: [
          ('What you told us', concerns.isEmpty ? null : concerns.join('\n')),
        ],
      ),
      DetailSection(
        title: 'Referred by',
        onEdit: () => Navigator.of(
          context,
        ).push(AppRoutes.profileEdit(OnboardingStep.referral)),
        rows: [('Referral source', p.snapshot?.referral?.label)],
      ),
      const Padding(
        padding: EdgeInsets.all(8),
        child: Text(
          'Tap Edit on a section to update your answers.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
      ),
    ];
  }
}
