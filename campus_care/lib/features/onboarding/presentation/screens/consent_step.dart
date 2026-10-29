import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../auth/presentation/viewModels/auth_provider.dart';
import '../../../models/consent.dart';
import '../../viewModels/onboarding_provider.dart';
import '../../widgets/step_frame.dart';
import '../../widgets/submit_state.dart';

class ConsentStep extends StatefulWidget {
  const ConsentStep({super.key});

  @override
  State<ConsentStep> createState() => _ConsentStepState();
}

class _ConsentStepState extends State<ConsentStep>
    with SubmitState<ConsentStep> {
  late bool _agreed = context
      .read<OnboardingProvider>()
      .snapshot
      .hasActiveConsent;

  Future<void> _submit() =>
      run(() => context.read<OnboardingProvider>().saveConsent());

  @override
  Widget build(BuildContext context) {
    return StepFrame(
      title: 'Consent & Privacy',
      subtitle:
          'Your privacy matters. Please read and agree to the following before continuing.',
      showBack: false,
      primaryLabel: 'Continue',
      onPrimary: _agreed ? _submit : null,
      loading: loading,
      error: error,
      children: [
        for (final s in Consent.statements)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(110),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline, color: AppColors.blue),
                  const SizedBox(width: 12),
                  Expanded(child: Text(s.text)),
                ],
              ),
            ),
          ),
        CheckboxListTile(
          value: _agreed,
          onChanged: loading
              ? null
              : (v) => setState(() => _agreed = v ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'I agree to the terms and conditions and privacy policy.',
          ),
        ),
        TextButton(
          onPressed: loading ? null : context.read<AuthProvider>().signOut,
          child: const Text('I do not agree, log me out'),
        ),
      ],
    );
  }
}
