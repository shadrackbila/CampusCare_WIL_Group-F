import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/options.dart';
import '../../../../../../core/utils/date_format.dart';
import '../../../../../../core/utils/validators.dart';
import '../../../../../../shared/widgets/app_dropdown.dart';
import '../../../../../../shared/widgets/app_text_field.dart';
import '../../../../models/personal_info.dart';
import '../../../viewModels/onboarding_provider.dart';
import '../../../widgets/app_date_field.dart';
import '../../../widgets/choice_chips_field.dart';
import '../../../widgets/multi_select_chips.dart';
import '../../../widgets/step_frame.dart';
import '../../../widgets/submit_state.dart';

class PersonalInfoStep extends StatefulWidget {
  const PersonalInfoStep({super.key});

  @override
  State<PersonalInfoStep> createState() => _PersonalInfoStepState();
}

class _PersonalInfoStepState extends State<PersonalInfoStep>
    with SubmitState<PersonalInfoStep> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _surname;
  late final TextEditingController _firstNames;
  late final TextEditingController _preferred;
  late final TextEditingController _nationality;
  DateTime? _dob;
  String? _gender;
  String? _homeLanguage;
  late Set<String> _otherLanguages;

  @override
  void initState() {
    super.initState();
    final p = context.read<OnboardingProvider>().snapshot.personal;
    _surname = TextEditingController(text: p.surname);
    _firstNames = TextEditingController(text: p.firstNames);
    _preferred = TextEditingController(text: p.preferredName);
    _nationality = TextEditingController(text: p.nationality);
    _dob = p.dateOfBirth;
    _gender = p.gender;
    _homeLanguage = p.homeLanguage;
    _otherLanguages = {...p.otherLanguages};
  }

  @override
  void dispose() {
    _surname.dispose();
    _firstNames.dispose();
    _preferred.dispose();
    _nationality.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final info = PersonalInfo(
      firstNames: _firstNames.text,
      surname: _surname.text,
      preferredName: _preferred.text,
      dateOfBirth: _dob,
      gender: _gender,
      nationality: _nationality.text,
      homeLanguage: _homeLanguage,
      otherLanguages: (_otherLanguages.toList()..sort()),
    );
    await run(() => context.read<OnboardingProvider>().savePersonal(info));
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return StepFrame(
      title: 'Personal Information',
      subtitle:
          'Please enter your details below. Fields marked optional can be left blank.',
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
                label: 'Surname',
                controller: _surname,
                validator: (v) => Validators.required(v, 'Surname'),
                textInputAction: TextInputAction.next,
                enabled: !loading,
              ),
              AppTextField(
                label: 'First name(s)',
                controller: _firstNames,
                validator: (v) => Validators.required(v, 'First name'),
                textInputAction: TextInputAction.next,
                enabled: !loading,
              ),
              AppTextField(
                label: 'Preferred name (optional)',
                controller: _preferred,
                textInputAction: TextInputAction.next,
                enabled: !loading,
              ),
              const SizedBox(height: 12),
              AppDateField(
                label: 'Date of birth',
                initialValue: _dob,
                firstDate: DateTime(now.year - 100),
                lastDate: now,
                validator: (d) => Validators.dateOfBirth(d),
                onChanged: (d) => setState(() => _dob = d),
                enabled: !loading,
              ),
              if (_dob != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text('Age: ${ageOn(_dob!, now)}'),
                ),
              const SizedBox(height: 16),
              ChoiceChipsField<String>(
                label: 'Gender',
                options: Options.genders,
                initialValue: _gender,
                onChanged: (v) => _gender = v,
                enabled: !loading,
              ),
              const SizedBox(height: 8),
              AppTextField(
                label: 'Nationality',
                controller: _nationality,
                validator: (v) => Validators.required(v, 'Nationality'),
                textInputAction: TextInputAction.next,
                enabled: !loading,
              ),
              const SizedBox(height: 12),
              AppDropdown<String>(
                label: 'Home language',
                items: AppDropdown.stringItems(Options.languages),
                value: _homeLanguage,
                validator: (v) => v == null ? 'Please choose a language' : null,
                onChanged: (v) => setState(() {
                  _homeLanguage = v;
                  if (v != null) _otherLanguages.remove(v);
                }),
                enabled: !loading,
              ),
              const SizedBox(height: 16),
              MultiSelectChips(
                label: 'Other languages (optional)',
                options: Options.languages,
                selected: _otherLanguages,
                disabled: {if (_homeLanguage != null) _homeLanguage!},
                onChanged: (s) => setState(() => _otherLanguages = s),
                enabled: !loading,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
