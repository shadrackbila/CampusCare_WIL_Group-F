import 'package:flutter/material.dart';

import '../../../../core/constants/options.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/date_format.dart';
import '../../../onboarding/models/onboarding_snapshot.dart';
import '../viewModels/profile_provider.dart';
import '../widgets/profile_scaffold.dart';

String? _label(List<Option<String>> options, String? value) {
  if (value == null) return null;
  for (final o in options) {
    if (o.value == value) return o.label;
  }
  return value;
}

/// What the student gave during onboarding, read-only (Figma page 30 "Personal Information").
class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfilePage(title: 'Personal Information', builder: _sections);
  }

  static List<Widget> _sections(BuildContext context, ProfileProvider p) {
    final s = p.snapshot!;
    final me = s.personal;
    final kin = s.nextOfKin;
    final acad = s.academic;
    final res = s.residence;
    return [
      DetailSection(
        title: 'About you',
        onEdit: () => Navigator.of(
          context,
        ).push(AppRoutes.profileEdit(OnboardingStep.personal)),
        rows: [
          ('Surname', me.surname),
          ('First name(s)', me.firstNames),
          ('Preferred name', me.preferredName),
          (
            'Date of birth',
            me.dateOfBirth == null ? null : formatDate(me.dateOfBirth!),
          ),
          ('Gender', _label(Options.genders, me.gender)),
          ('Nationality', me.nationality),
          ('Home language', me.homeLanguage),
          ('Other languages', me.otherLanguages.join(', ')),
        ],
      ),
      DetailSection(
        title: 'Next of kin',
        onEdit: () => Navigator.of(
          context,
        ).push(AppRoutes.profileEdit(OnboardingStep.nextOfKin)),
        rows: [
          ('Full name', kin?.fullName),
          ('Relationship', kin?.relationship),
          ('Cell number', kin?.cellNumber),
          ('Alternative number', kin?.alternativeNumber),
          ('Email', kin?.email),
          ('Address', kin?.residentialAddress),
        ],
      ),
      DetailSection(
        title: 'Academic',
        onEdit: () => Navigator.of(
          context,
        ).push(AppRoutes.profileEdit(OnboardingStep.academic)),
        rows: [
          ('Faculty', acad?.faculty),
          ('Department', acad?.department),
          ('Qualification / programme', acad?.qualification),
          ('Year of study', _label(Options.yearsOfStudy, acad?.yearOfStudy)),
          ('Mode of study', _label(Options.studyModes, acad?.studyMode)),
          (
            'Campus',
            acad?.campus == 'other' && acad!.campusOther.isNotEmpty
                ? acad.campusOther
                : _label(Options.campuses, acad?.campus),
          ),
        ],
      ),
      DetailSection(
        title: 'Residence',
        onEdit: () => Navigator.of(
          context,
        ).push(AppRoutes.profileEdit(OnboardingStep.residence)),
        rows: [
          (
            'Type of residence',
            _label(Options.residenceTypes, res?.residenceType),
          ),
          if (res?.isCut ?? false) ...[
            ('Residence name', res?.residenceName),
            ('Room number', res?.roomNumber),
          ] else ...[
            ('Address', res?.address),
            ('City', res?.city),
            ('Postal code', res?.postalCode),
            ('Province', res?.province),
          ],
        ],
      ),
      const Padding(
        padding: EdgeInsets.all(8),
        child: Text(
          'Tap Edit on a section to update your details.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
      ),
    ];
  }
}
