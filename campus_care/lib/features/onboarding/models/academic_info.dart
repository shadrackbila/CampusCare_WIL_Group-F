class AcademicInfo {
  const AcademicInfo({
    this.faculty = '',
    this.department = '',
    this.qualification = '',
    this.yearOfStudy,
    this.studyMode,
    this.campus,
    this.campusOther = '',
  });

  final String faculty;
  final String department;
  final String qualification;
  final String? yearOfStudy;
  final String? studyMode;
  final String? campus;
  final String campusOther;

  factory AcademicInfo.fromRow(Map<String, dynamic> j) => AcademicInfo(
        faculty: (j['faculty'] as String?) ?? '',
        department: (j['department'] as String?) ?? '',
        qualification: (j['qualification'] as String?) ?? '',
        yearOfStudy: j['year_of_study'] as String?,
        studyMode: j['study_mode'] as String?,
        campus: j['campus'] as String?,
        campusOther: (j['campus_other'] as String?) ?? '',
      );

  Map<String, dynamic> toUpsert(String studentId) => {
        'student_id': studentId,
        'faculty': faculty.trim(),
        'department': department.trim(),
        'qualification': qualification.trim(),
        'year_of_study': yearOfStudy,
        'study_mode': studyMode,
        'campus': campus,
        'campus_other':
            campus == 'other' && campusOther.trim().isNotEmpty ? campusOther.trim() : null,
      };

  bool get isComplete =>
      faculty.trim().isNotEmpty &&
      department.trim().isNotEmpty &&
      qualification.trim().isNotEmpty &&
      yearOfStudy != null &&
      studyMode != null &&
      campus != null &&
      (campus != 'other' || campusOther.trim().isNotEmpty);
}
