class Option<T> {
  const Option(this.value, this.label);
  final T value;
  final String label;
}

// --- CUT academic structure ---
class CutProgramme {
  const CutProgramme(this.name, this.type);
  final String name;
  final String type; // e.g. 'Diploma', 'Bachelor', 'Advanced Diploma'
}

class CutDepartment {
  const CutDepartment(this.name, this.programmes);
  final String name;
  final List<CutProgramme> programmes;
}

class CutFaculty {
  const CutFaculty(this.name, this.departments);
  final String name;
  final List<CutDepartment> departments;
}
// -----------------------------

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
    'Afrikaans',
    'English',
    'isiNdebele',
    'isiXhosa',
    'isiZulu',
    'Sepedi',
    'Sesotho',
    'Setswana',
    'siSwati',
    'Tshivenda',
    'Xitsonga',
    'Other',
  ];

  static const provinces = <String>[
    'Eastern Cape',
    'Free State',
    'Gauteng',
    'KwaZulu-Natal',
    'Limpopo',
    'Mpumalanga',
    'Northern Cape',
    'North West',
    'Western Cape',
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

  /// The complete academic structure of CUT (Faculties → Departments → Programmes).
  /// Source: CUT Prospectus and Faculty pages. Verify against the latest prospectus.
  static const cutFaculties = <CutFaculty>[
    CutFaculty(
      'Faculty of Engineering, Built Environment and Information Technology',
      [
        CutDepartment('Built Environment', [
          CutProgramme('National Diploma: Building', 'Diploma'),
          CutProgramme('Higher Certificate: Construction', 'Certificate'),
          CutProgramme('Bachelor of Construction Management', 'Bachelor'),
          CutProgramme('Bachelor of Quantity Surveying', 'Bachelor'),
        ]),
        CutDepartment('Civil Engineering', [
          CutProgramme('National Diploma: Civil Engineering', 'Diploma'),
          CutProgramme('Bachelor of Civil Engineering', 'Bachelor'),
          CutProgramme(
            'BSc: Hydrology and Water Resources Management',
            'Bachelor',
          ),
          CutProgramme(
            'Advanced Diploma: Logistics and Transportation Management',
            'Advanced Diploma',
          ),
        ]),
        CutDepartment('Electrical, Electronic and Computer Engineering', [
          CutProgramme(
            'Higher Certificate: Renewable Energy Technologies',
            'Certificate',
          ),
          CutProgramme(
            'National Diploma: Computer Systems Engineering',
            'Diploma',
          ),
          CutProgramme(
            'National Diploma: Electrical Engineering (Heavy Current)',
            'Diploma',
          ),
          CutProgramme(
            'National Diploma: Electrical Engineering (Light Current)',
            'Diploma',
          ),
          CutProgramme('Bachelor of Electrical Engineering', 'Bachelor'),
        ]),
        CutDepartment('Information Technology', [
          CutProgramme(
            'National Diploma: Information Technology (Software Development)',
            'Diploma',
          ),
          CutProgramme(
            'National Diploma: Information Technology (Web and Application Development)',
            'Diploma',
          ),
          CutProgramme('Diploma in Computer Networking', 'Diploma'),
          CutProgramme('Diploma in Information Technology', 'Diploma'),
        ]),
        CutDepartment('Mathematical and Physical Sciences', []),
        CutDepartment('Mechanical and Mechatronic Engineering', [
          CutProgramme('National Diploma: Mechanical Engineering', 'Diploma'),
          CutProgramme('Bachelor of Mechanical Engineering', 'Bachelor'),
        ]),
      ],
    ),
    CutFaculty('Faculty of Health and Environmental Sciences', [
      CutDepartment('Agriculture', [
        CutProgramme('National Diploma: Agricultural Management', 'Diploma'),
        CutProgramme(
          'Advanced Diploma: Agricultural Extension and Advising',
          'Advanced Diploma',
        ),
      ]),
      CutDepartment('Clinical Sciences', [
        CutProgramme('Diploma in Emergency Medical Care', 'Diploma'),
        CutProgramme('Diploma in Radiography: Nuclear Medicine', 'Diploma'),
        CutProgramme('Diploma in Radiography: Therapy', 'Diploma'),
        CutProgramme('Bachelor of Radiography in Diagnostics', 'Bachelor'),
      ]),
      CutDepartment('Health Sciences', [
        CutProgramme('Diploma in Biomedical Technology', 'Diploma'),
        CutProgramme('Diploma in Clinical Technology', 'Diploma'),
        CutProgramme(
          'Bachelor in Health Sciences in Clinical Technology',
          'Bachelor',
        ),
        CutProgramme('Bachelor in Environmental Health', 'Bachelor'),
      ]),
      CutDepartment('Life Sciences', [
        CutProgramme('National Diploma: Environmental Health', 'Diploma'),
      ]),
      CutDepartment('Somatology', [
        CutProgramme('Higher Certificate: Dental Assisting', 'Certificate'),
        CutProgramme('National Diploma: Somatology', 'Diploma'),
      ]),
    ]),
    CutFaculty('Faculty of Humanities', [
      CutDepartment('Communication Sciences', [
        CutProgramme('National Diploma: Language Practice', 'Diploma'),
        CutProgramme(
          'Diploma in Language Practice and Media Studies',
          'Diploma',
        ),
        CutProgramme('Bachelor of Arts in Media Studies', 'Bachelor'),
      ]),
      CutDepartment('Design and Studio Art', [
        CutProgramme('National Diploma in Design and Studio Art', 'Diploma'),
        CutProgramme('National Diploma: Clothing', 'Diploma'),
        CutProgramme('National Diploma: Fashion', 'Diploma'),
        CutProgramme('National Diploma: Fine Art', 'Diploma'),
        CutProgramme('National Diploma: Graphic Design', 'Diploma'),
        CutProgramme('National Diploma: Photography', 'Diploma'),
        CutProgramme('Bachelor of Arts in Design Technology', 'Bachelor'),
      ]),
      CutDepartment('Educational and Professional Studies', []),
      CutDepartment('Language and Social Sciences Education', [
        CutProgramme(
          'Bachelor of Education in Senior Phase & FET Teaching: Specialisation: Languages',
          'Bachelor',
        ),
      ]),
      CutDepartment('Mathematics, Science & Technology Education', [
        CutProgramme('BEd (FET): Specialisation: Natural Sciences', 'Bachelor'),
        CutProgramme('BEd (FET): Specialisation: Technology', 'Bachelor'),
        CutProgramme(
          'Bachelor of Education in Senior Phase and FET Teaching: Specialisation: Natural Sciences',
          'Bachelor',
        ),
        CutProgramme(
          'Bachelor of Education in Senior Phase and FET Teaching: Specialisation: Technology',
          'Bachelor',
        ),
        CutProgramme(
          'Bachelor of Education in Senior Phase and FET Teaching: Specialisation: Computer Science',
          'Bachelor',
        ),
      ]),
      CutDepartment('Postgraduate Studies', []),
    ]),
    CutFaculty('Faculty of Management Sciences', [
      CutDepartment('Accounting and Auditing', [
        CutProgramme('Accounting Technician (AAT)', 'Certificate'),
        CutProgramme('National Higher Certificate: Accounting', 'Certificate'),
        CutProgramme('National Diploma: Internal Auditing', 'Diploma'),
        CutProgramme(
          'National Higher Certificate: Financial Information Systems',
          'Certificate',
        ),
        CutProgramme(
          'National Diploma: Financial Information Systems',
          'Diploma',
        ),
        CutProgramme(
          'National Diploma: Cost and Management Accounting',
          'Diploma',
        ),
      ]),
      CutDepartment('Business Management', [
        CutProgramme('National Diploma: Human Resources', 'Diploma'),
        CutProgramme('Diploma in Human Resources Management', 'Diploma'),
        CutProgramme('National Diploma: Marketing', 'Diploma'),
        CutProgramme('Diploma in Marketing Management', 'Diploma'),
      ]),
      CutDepartment('Business Support Studies', []),
      CutDepartment('Government Management', [
        CutProgramme('National Diploma: Public Management', 'Diploma'),
        CutProgramme('NDip: Office Management and Technology', 'Diploma'),
      ]),
      CutDepartment('Hospitality Management', [
        CutProgramme('National Diploma: Hospitality Management', 'Diploma'),
      ]),
      CutDepartment('Tourism and Events Management', [
        CutProgramme('National Diploma: Tourism', 'Diploma'),
      ]),
    ]),
  ];
}
