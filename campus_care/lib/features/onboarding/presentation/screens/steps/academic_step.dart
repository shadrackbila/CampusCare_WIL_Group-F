import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/options.dart';
import '../../../../../../core/utils/validators.dart';
import '../../../../../../shared/widgets/app_text_field.dart';
import '../../../../models/academic_info.dart';
import '../../../viewModels/onboarding_provider.dart';
import '../../../widgets/choice_chips_field.dart';
import '../../../widgets/step_frame.dart';
import '../../../widgets/submit_state.dart';

class AcademicStep extends StatefulWidget {
  const AcademicStep({super.key});

  @override
  State<AcademicStep> createState() => _AcademicStepState();
}

class _AcademicStepState extends State<AcademicStep>
    with SubmitState<AcademicStep> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _faculty;
  late final TextEditingController _department;
  late final TextEditingController _qualification;
  late final TextEditingController _campusOther;
  String? _year;
  String? _mode;
  String? _campus;

  @override
  void initState() {
    super.initState();
    final a =
        context.read<OnboardingProvider>().snapshot.academic ??
        const AcademicInfo();
    _faculty = TextEditingController(text: a.faculty);
    _department = TextEditingController(text: a.department);
    _qualification = TextEditingController(text: a.qualification);
    _campusOther = TextEditingController(text: a.campusOther);
    _year = a.yearOfStudy;
    _mode = a.studyMode;
    _campus = a.campus;
  }

  @override
  void dispose() {
    for (final c in [_faculty, _department, _qualification, _campusOther]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final info = AcademicInfo(
      faculty: _faculty.text,
      department: _department.text,
      qualification: _qualification.text,
      yearOfStudy: _year,
      studyMode: _mode,
      campus: _campus,
      campusOther: _campusOther.text,
    );
    await run(() => context.read<OnboardingProvider>().saveAcademic(info));
  }

  @override
  Widget build(BuildContext context) {
    return StepFrame(
      title: 'Academic Info',
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
              AppTextField(
                label: 'Faculty',
                controller: _faculty,
                validator: (v) => Validators.required(v, 'Faculty'),
                textInputAction: TextInputAction.next,
                enabled: !loading,
              ),
              AppTextField(
                label: 'Department',
                controller: _department,
                validator: (v) => Validators.required(v, 'Department'),
                textInputAction: TextInputAction.next,
                enabled: !loading,
              ),
              AppTextField(
                label: 'Qualification / Programme',
                controller: _qualification,
                validator: (v) => Validators.required(v, 'Qualification'),
                textInputAction: TextInputAction.done,
                enabled: !loading,
              ),
              const SizedBox(height: 16),
              ChoiceChipsField<String>(
                label: 'Year of study',
                options: Options.yearsOfStudy,
                initialValue: _year,
                onChanged: (v) => _year = v,
                enabled: !loading,
              ),
              const SizedBox(height: 16),
              ChoiceChipsField<String>(
                label: 'Mode of study',
                options: Options.studyModes,
                initialValue: _mode,
                onChanged: (v) => _mode = v,
                enabled: !loading,
              ),
              const SizedBox(height: 16),
              ChoiceChipsField<String>(
                label: 'Campus',
                options: Options.campuses,
                initialValue: _campus,
                onChanged: (v) => setState(() => _campus = v),
                enabled: !loading,
              ),
              if (_campus == 'other')
                AppTextField(
                  label: 'Which campus?',
                  controller: _campusOther,
                  validator: (v) => Validators.required(v, 'Campus'),
                  enabled: !loading,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
