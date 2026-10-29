import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/utils/validators.dart';
import '../../../../../../shared/widgets/app_text_field.dart';
import '../../../../models/next_of_kin.dart';
import '../../../viewModels/onboarding_provider.dart';
import '../../../widgets/step_frame.dart';
import '../../../widgets/submit_state.dart';

class NextOfKinStep extends StatefulWidget {
  const NextOfKinStep({super.key});

  @override
  State<NextOfKinStep> createState() => _NextOfKinStepState();
}

class _NextOfKinStepState extends State<NextOfKinStep>
    with SubmitState<NextOfKinStep> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _relationship;
  late final TextEditingController _cell;
  late final TextEditingController _alt;
  late final TextEditingController _email;
  late final TextEditingController _address;

  @override
  void initState() {
    super.initState();
    final k =
        context.read<OnboardingProvider>().snapshot.nextOfKin ??
        const NextOfKin();
    _name = TextEditingController(text: k.fullName);
    _relationship = TextEditingController(text: k.relationship);
    _cell = TextEditingController(text: k.cellNumber);
    _alt = TextEditingController(text: k.alternativeNumber);
    _email = TextEditingController(text: k.email);
    _address = TextEditingController(text: k.residentialAddress);
  }

  @override
  void dispose() {
    for (final c in [_name, _relationship, _cell, _alt, _email, _address]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final kin = NextOfKin(
      fullName: _name.text,
      relationship: _relationship.text,
      cellNumber: _cell.text,
      alternativeNumber: _alt.text,
      email: _email.text,
      residentialAddress: _address.text,
    );
    await run(() => context.read<OnboardingProvider>().saveNextOfKin(kin));
  }

  @override
  Widget build(BuildContext context) {
    return StepFrame(
      title: 'Next of kin',
      subtitle: 'Someone we can contact in an emergency.',
      primaryLabel: 'Next',
      onPrimary: _submit,
      loading: loading,
      error: error,
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'Full name',
                controller: _name,
                validator: (v) => Validators.required(v, 'Full name'),
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                enabled: !loading,
              ),
              AppTextField(
                label: 'Relationship to you',
                controller: _relationship,
                validator: (v) => Validators.required(v, 'Relationship'),
                textInputAction: TextInputAction.next,
                enabled: !loading,
              ),
              AppTextField(
                label: 'Cell number',
                controller: _cell,
                validator: Validators.phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                enabled: !loading,
              ),
              AppTextField(
                label: 'Alternative number (optional)',
                controller: _alt,
                validator: (v) => Validators.phone(v, requiredField: false),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                enabled: !loading,
              ),
              AppTextField(
                label: 'Email (optional)',
                controller: _email,
                validator: Validators.optionalEmail,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                enabled: !loading,
              ),
              AppTextField(
                label: 'Residential address (optional)',
                controller: _address,
                keyboardType: TextInputType.streetAddress,
                textInputAction: TextInputAction.done,
                enabled: !loading,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
