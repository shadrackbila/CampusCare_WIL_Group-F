/// The logged-in student's row in `public.students`.
class Student {
  const Student({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.studentNumber,
    required this.universityEmail,
    this.preferredName,
    this.intakeCompletedAt,
  });

  final String id;
  final String userId;
  final String fullName;
  final String studentNumber;
  final String universityEmail;
  final String? preferredName;
  final DateTime? intakeCompletedAt;

  bool get onboardingComplete => intakeCompletedAt != null;

  String get displayName {
    final preferred = preferredName?.trim();
    return (preferred != null && preferred.isNotEmpty) ? preferred : fullName;
  }

  static const selectColumns =
      'id, user_id, full_name, preferred_name, student_number, university_email, intake_completed_at';

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        fullName: json['full_name'] as String,
        studentNumber: json['student_number'] as String,
        universityEmail: json['university_email'] as String,
        preferredName: json['preferred_name'] as String?,
        intakeCompletedAt: json['intake_completed_at'] == null
            ? null
            : DateTime.parse(json['intake_completed_at'] as String),
      );
}
