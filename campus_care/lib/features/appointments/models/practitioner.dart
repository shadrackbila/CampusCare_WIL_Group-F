class Practitioner {
  const Practitioner({
    required this.id,
    required this.fullName,
    required this.role,
    this.title,
    this.gender,
    this.photoUrl,
  });

  final String id;
  final String fullName;
  final String role;
  final String? title;
  final String? gender;
  final String? photoUrl;

  /// e.g. "Dr Mokoena"
  String get displayName {
    final t = title?.trim() ?? '';
    return t.isEmpty ? fullName : '$t $fullName';
  }

  String get roleLabel => roleLabelFor(role);

  static String roleLabelFor(String role) {
    switch (role) {
      case 'wellness_practitioner':
        return 'Wellness Practitioner';
      case 'counselor':
        return 'Counsellor';
      case 'psychologist':
        return 'Psychologist';
      case 'social_worker':
        return 'Social Worker';
      case 'nurse':
        return 'Nurse';
      default:
        return 'Practitioner';
    }
  }

  static const selectColumns = 'id, full_name, title, role, gender, photo_url';

  factory Practitioner.fromJson(Map<String, dynamic> j) => Practitioner(
        id: j['id'] as String,
        fullName: j['full_name'] as String,
        role: (j['role'] as String?) ?? 'other',
        title: j['title'] as String?,
        gender: (j['gender'] as String?)?.toLowerCase(),
        photoUrl: j['photo_url'] as String?,
      );
}
