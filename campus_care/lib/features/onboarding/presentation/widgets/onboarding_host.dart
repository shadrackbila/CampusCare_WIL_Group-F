import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/auth_scaffold.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../auth/presentation/viewModels/auth_provider.dart';
import '../../models/onboarding_snapshot.dart';
import '../screens/steps/academic_step.dart';
import '../screens/steps/concerns_step.dart';
import '../screens/steps/consent_step.dart';
import '../screens/steps/next_of_kin_step.dart';
import '../screens/steps/personal_info_step.dart';
import '../screens/steps/referral_step.dart';
import '../screens/steps/residence_step.dart';
import '../viewModels/onboarding_provider.dart';

/// Shows the current step. Also used by the Profile tab to edit a single step.
class OnboardingHost extends StatelessWidget {
  const OnboardingHost({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<OnboardingProvider>();

    switch (p.loadState) {
      case OnboardingLoad.loading:
        return const AuthScaffold(
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        );
      case OnboardingLoad.error:
        return AuthScaffold(
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "We couldn't load your information",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(p.loadError ?? 'Please try again.'),
                const SizedBox(height: 20),
                AppButton(label: 'Retry', onPressed: p.load),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Log out',
                  style: AppButtonStyle.outlined,
                  onPressed: context.read<AuthProvider>().signOut,
                ),
              ],
            ),
          ),
        );
      case OnboardingLoad.ready:
        return switch (p.step) {
          OnboardingStep.consent => const ConsentStep(),
          OnboardingStep.personal => const PersonalInfoStep(),
          OnboardingStep.nextOfKin => const NextOfKinStep(),
          OnboardingStep.academic => const AcademicStep(),
          OnboardingStep.residence => const ResidenceStep(),
          OnboardingStep.concerns => const ConcernsStep(),
          OnboardingStep.referral => const ReferralStep(),
        };
    }
  }
}
