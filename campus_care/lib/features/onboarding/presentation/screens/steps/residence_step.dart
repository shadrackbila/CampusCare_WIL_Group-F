import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/options.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../../shared/widgets/app_dropdown.dart';
import '../../../../../shared/widgets/app_text_field.dart';
import '../../../models/residence_info.dart';
import '../../viewModels/onboarding_provider.dart';
import '../../widgets/choice_chips_field.dart';
import '../../widgets/step_frame.dart';
import '../../widgets/submit_state.dart';

class ResidenceStep extends StatefulWidget {
  const ResidenceStep({super.key});

  @override
  State<ResidenceStep> createState() => _ResidenceStepState();
}

class _ResidenceStepState extends State<ResidenceStep>
    with SubmitState<ResidenceStep> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _room;
  late final TextEditingController _address;
  late final TextEditingController _city;
  late final TextEditingController _postal;
  String? _type;
  String? _province;

  @override
  void initState() {
    super.initState();
    final r =
        context.read<OnboardingProvider>().snapshot.residence ??
        const ResidenceInfo();
    _name = TextEditingController(text: r.residenceName);
    _room = TextEditingController(text: r.roomNumber);
    _address = TextEditingController(text: r.address);
    _city = TextEditingController(text: r.city);
    _postal = TextEditingController(text: r.postalCode);
    _type = r.residenceType;
    _province = r.province;
  }

  @override
  void dispose() {
    for (final c in [_name, _room, _address, _city, _postal]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final info = ResidenceInfo(
      residenceType: _type,
      residenceName: _name.text,
      roomNumber: _room.text,
      address: _address.text,
      city: _city.text,
      postalCode: _postal.text,
      province: _province,
    );
    await run(() => context.read<OnboardingProvider>().saveResidence(info));
  }

  @override
  Widget build(BuildContext context) {
    return StepFrame(
      title: 'Residential Info',
      subtitle: 'Please enter your details below.',
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
              ChoiceChipsField<String>(
                label: 'Type of residence',
                options: Options.residenceTypes,
                initialValue: _type,
                onChanged: (v) => setState(() => _type = v),
                enabled: !loading,
              ),
              const SizedBox(height: 8),
              if (_type == 'cut') ...[
                AppTextField(
                  label: 'Name of residence',
                  controller: _name,
                  validator: (v) => Validators.required(v, 'Residence name'),
                  textInputAction: TextInputAction.next,
                  enabled: !loading,
                ),
                AppTextField(
                  label: 'Room number (optional)',
                  controller: _room,
                  textInputAction: TextInputAction.done,
                  enabled: !loading,
                ),
              ],
              if (_type == 'private') ...[
                AppTextField(
                  label: 'Address',
                  controller: _address,
                  validator: (v) => Validators.required(v, 'Address'),
                  keyboardType: TextInputType.streetAddress,
                  textInputAction: TextInputAction.next,
                  enabled: !loading,
                ),
                AppTextField(
                  label: 'City',
                  controller: _city,
                  validator: (v) => Validators.required(v, 'City'),
                  textInputAction: TextInputAction.next,
                  enabled: !loading,
                ),
                AppTextField(
                  label: 'Postal code',
                  controller: _postal,
                  validator: Validators.postalCode,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  enabled: !loading,
                ),
                const SizedBox(height: 12),
                AppDropdown<String>(
                  label: 'Province',
                  items: AppDropdown.stringItems(Options.provinces),
                  value: _province,
                  validator: (v) =>
                      v == null ? 'Please choose a province' : null,
                  onChanged: (v) => setState(() => _province = v),
                  enabled: !loading,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
