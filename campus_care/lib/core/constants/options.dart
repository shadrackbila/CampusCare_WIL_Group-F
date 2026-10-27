class Option<T> {
  const Option(this.value, this.label);
  final T value;
  final String label;
}

/// Fixed answer lists. Codes must match the database CHECK constraints.
class Options {
  const Options._();

  static const genders = <Option<String>>[
    Option('male', 'Male'),
    Option('female', 'Female'),
    Option('non_binary', 'Non-binary'),
    Option('prefer_not_to_say', 'Prefer not to say'),
  ];

  static const languages = <String>[
    'Afrikaans', 'English', 'isiNdebele', 'isiXhosa', 'isiZulu', 'Sepedi',
    'Sesotho', 'Setswana', 'siSwati', 'Tshivenda', 'Xitsonga', 'Other',
  ];

  static const provinces = <String>[
    'Eastern Cape', 'Free State', 'Gauteng', 'KwaZulu-Natal', 'Limpopo',
    'Mpumalanga', 'Northern Cape', 'North West', 'Western Cape',
  ];

  static const yearsOfStudy = <Option<String>>[
    Option('1st', '1st'),
    Option('2nd', '2nd'),
    Option('3rd', '3rd'),
    Option('4th', '4th'),
    Option('honours', 'Honours'),
  ];

  static const studyModes = <Option<String>>[
    Option('full_time', 'Full-time'),
    Option('part_time', 'Part-time'),
  ];

  static const campuses = <Option<String>>[
    Option('bloemfontein', 'Bloemfontein'),
    Option('welkom', 'Welkom'),
    Option('other', 'Other'),
  ];

  static const residenceTypes = <Option<String>>[
    Option('cut', 'CUT residence'),
    Option('private', 'Private accommodation'),
  ];
}
