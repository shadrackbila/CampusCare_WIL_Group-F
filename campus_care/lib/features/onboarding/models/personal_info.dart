import '../../../core/utils/date_format.dart';

class PersonalInfo {
  const PersonalInfo({
    this.firstNames = '',
    this.surname = '',
    this.preferredName = '',
    this.dateOfBirth,
    this.gender,
    this.nationality = '',
    this.homeLanguage,
    this.otherLanguages = const [],
  });

  final String firstNames;
  final String surname;
  final String preferredName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String nationality;
  final String? homeLanguage;
  final List<String> otherLanguages;


  static const selectColumns =
      'first_names, surname, preferred_name, date_of_birth, gender, nationality, home_language, other_languages';

  factory PersonalInfo.fromRow(Map<String, dynamic> j) =>
      PersonalInfo(
        firstNames: (j['first_names'] as String?) ?? '',
        surname: (j['surname'] as String?) ?? '',
        preferredName: (j['preferred_name'] as String?) ?? '',
        dateOfBirth: j['date_of_birth'] == null
            ? null
            : DateTime.parse(j['date_of_birth'] as String),
        gender: j['gender'] as String?,
        nationality: (j['nationality'] as String?) ?? '',
        homeLanguage: j['home_language'] as String?,
        otherLanguages: ((j['other_languages'] as List?) ?? const [])
            .map((e) => e as String)
            .toList(),
      );

  Map<String, dynamic> toUpdate() => {
        'first_names': firstNames.trim(),
        'surname': surname.trim(),
        'preferred_name': preferredName.trim().isEmpty ? null : preferredName.trim(),
        'date_of_birth': dateOfBirth == null ? null : toIsoDate(dateOfBirth!),
        'gender': gender,
        'nationality': nationality.trim(),
        'home_language': homeLanguage,
        'other_languages': otherLanguages,
      };

  bool get isComplete =>
      firstNames.trim().isNotEmpty &&
      surname.trim().isNotEmpty &&
      dateOfBirth != null &&
      gender != null &&
      nationality.trim().isNotEmpty &&
      homeLanguage != null;

}
