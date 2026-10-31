import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/viewModels/auth_provider.dart';
import '../../data/onboarding_repository.dart';
import '../viewModels/onboarding_provider.dart';
import '../widgets/onboarding_host.dart';

/// Hosts the onboarding wizard. Resumes at the first incomplete step.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<OnboardingProvider>(
      create: (ctx) => OnboardingProvider(
        ctx.read<OnboardingRepository>(),
        ctx.read<AuthProvider>().student!.id,
      )..load(),
      child: const OnboardingHost(),
    );
  }
}
