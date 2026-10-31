/// Current consent wording. Bump [version] whenever the statements change so the
/// stored record shows exactly what a student agreed to.
class Consent {
  const Consent._();

  static const version = 'v1';

  static const statements = <ConsentStatement>[
    ConsentStatement(
      'confidential_access',
      'Your information is confidential and will only be accessed by authorised CUT Wellness Centre staff.',
    ),
    ConsentStatement('popia', 'Your data is protected in accordance with POPIA.'),
    ConsentStatement('withdraw_anytime', 'You can withdraw your consent at any time.'),
    ConsentStatement(
      'wellbeing_use',
      'You agree that the information you provide may be used to support your wellbeing and care.',
    ),
  ];

  /// Recorded alongside the statements when the student ticks the box.
  static const termsCode = 'terms_and_privacy';

  static List<String> get acceptedCodes =>
      [...statements.map((s) => s.code), termsCode];
}

class ConsentStatement {
  const ConsentStatement(this.code, this.text);
  final String code;
  final String text;
}
