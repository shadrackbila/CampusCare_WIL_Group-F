import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewModels/onboarding_provider.dart';
import '../../widgets/step_frame.dart';
import '../../widgets/submit_state.dart';

class ConcernsStep extends StatefulWidget {
  const ConcernsStep({super.key});

  @override
  State<ConcernsStep> createState() => _ConcernsStepState();
}

class _ConcernsStepState extends State<ConcernsStep>
    with SubmitState<ConcernsStep> {
  late Set<String> _selected = {
    ...context.read<OnboardingProvider>().snapshot.concernCodes,
  };

  Future<void> _submit() =>
      run(() => context.read<OnboardingProvider>().saveConcerns(_selected));

  @override
  Widget build(BuildContext context) {
    final catalog = context.read<OnboardingProvider>().concernCatalog;
    return StepFrame(
      title: 'Presenting Concerns',
      subtitle: 'Tick all that apply. You can choose none.',
      primaryLabel: 'Next',
      onPrimary: _submit,
      loading: loading,
      error: error,
      children: [
        for (final c in catalog)
          CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _selected.contains(c.code),
            title: Text(c.label),
            onChanged: loading
                ? null
                : (on) => setState(() {
                    final next = {..._selected};
                    (on ?? false) ? next.add(c.code) : next.remove(c.code);
                    _selected = next;
                  }),
          ),
        const SizedBox(height: 8),
        // The "is high risk" flag is never shown to students; this note is for everyone.
        const Text(
          'If you need urgent help right now, call the CUT Wellness Centre on 051 507 9020.',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
