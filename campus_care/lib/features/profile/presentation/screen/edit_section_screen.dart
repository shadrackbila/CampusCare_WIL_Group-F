import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/auth_scaffold.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../auth/presentation/viewModels/auth_provider.dart';
import '../../../onboarding/data/onboarding_repository.dart';
import '../../../onboarding/models/onboarding_snapshot.dart';
import '../../../onboarding/presentation/viewModels/onboarding_provider.dart';
import '../../../onboarding/presentation/widgets/onboarding_host.dart';
import '../viewModels/profile_provider.dart';

/// Edits one onboarding section from the Profile tab by reusing the onboarding step forms,
/// so the same fields and validation apply. Saving goes through the same repository calls.
class EditSectionScreen extends StatelessWidget {
  const EditSectionScreen({super.key, required this.section});

  /// An [OnboardingStep] name, e.g. "personal" or "nextOfKin".
  final String section;

  static OnboardingStep? parse(String name) {
    for (final s in OnboardingStep.values) {
      if (s.name == name && s != OnboardingStep.consent) return s;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final step = parse(section);
    final student = context.read<AuthProvider>().student;
    if (step == null || student == null) {
      return AuthScaffold(
        child: GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('This section cannot be edited.'),
              const SizedBox(height: 16),
              AppButton(
                label: 'Back',
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),
      );
    }
    return ChangeNotifierProvider<OnboardingProvider>(
      create: (ctx) => OnboardingProvider(
        ctx.read<OnboardingRepository>(),
        student.id,
        editStep: step,
      )..load(),
      child: const _CloseWhenSaved(child: OnboardingHost()),
    );
  }
}

class _CloseWhenSaved extends StatefulWidget {
  const _CloseWhenSaved({required this.child});

  final Widget child;

  @override
  State<_CloseWhenSaved> createState() => _CloseWhenSavedState();
}

class _CloseWhenSavedState extends State<_CloseWhenSaved> {
  bool _handled = false;

  @override
  Widget build(BuildContext context) {
    final saved = context.select<OnboardingProvider, bool>((p) => p.saved);
    if (saved && !_handled) {
      _handled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        final nav = Navigator.of(context);
        context.read<ProfileProvider>().load();
        context.read<AuthProvider>().reloadStudent();
        messenger.showSnackBar(
          const SnackBar(content: Text('Your changes have been saved.')),
        );
        if (nav.canPop()) nav.pop();
      });
    }
    return widget.child;
  }
}
