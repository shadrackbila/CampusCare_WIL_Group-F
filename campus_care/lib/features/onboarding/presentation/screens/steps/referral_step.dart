import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/options.dart';
import '../../../../../auth/presentation/viewModels/auth_provider.dart';
import '../../../../models/referral_source.dart';
import '../../../viewModels/onboarding_provider.dart';
import '../../../widgets/choice_chips_field.dart';
import '../../../widgets/step_frame.dart';
import '../../../widgets/submit_state.dart';

class ReferralStep extends StatefulWidget {
  const ReferralStep({super.key});

  @override
  State<ReferralStep> createState() => _ReferralStepState();
}

class _ReferralStepState extends State<ReferralStep>
    with SubmitState<ReferralStep> {
  final _formKey = GlobalKey<FormState>();
  ReferralSource? _source;

  @override
  void initState() {
    super.initState();
    _source = context.read<OnboardingProvider>().snapshot.referral;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final onboarding = context.read<OnboardingProvider>();
    final auth = context.read<AuthProvider>();
    final source = _source!;
    await run(() async {
      await onboarding.saveReferralAndComplete(source);
      // Re-read the profile: intake_completed_at is now set, so the router
      // leaves onboarding and opens Home.
      if (!onboarding.editing) await auth.refreshStudent();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StepFrame(
      title: 'Who referred you?',
      subtitle: 'Tick one.',
      primaryLabel: 'Complete',
      onPrimary: _submit,
      loading: loading,
      error: error,
      children: [
        Form(
          key: _formKey,
          child: ChoiceChipsField<ReferralSource>(
            label: 'Referred by',
            options: [
              for (final r in ReferralSource.values) Option(r, r.label),
            ],
            initialValue: _source,
            onChanged: (v) => _source = v,
            enabled: !loading,
            requiredMessage: 'Please choose one',
          ),
        ),
      ],
    );
  }
}
