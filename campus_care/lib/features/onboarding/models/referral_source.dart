/// "Who referred you?" (tick one). Codes match the student_intake CHECK constraint.
enum ReferralSource {
  self('self', 'Self'),
  residenceMentor('residence_mentor', 'Residence Mentor'),
  lecturer('lecturer', 'Lecturer'),
  campusClinicStaff('campus_clinic_staff', 'Campus Clinic Staff'),
  facultyOfficer('faculty_officer', 'Faculty Officer / Administrator'),
  studentAdmin('student_admin_enrollment', 'Student Admin and Enrollment'),
  friend('friend', 'Friend'),
  peerEducator('peer_educator', 'Peer Educator'),
  parentGuardian('parent_guardian', 'Parent / Guardian'),
  academicAdvisor('academic_advisor', 'Academic Advisor'),
  residenceArm('residence_arm', 'Residence ARM'),
  academicMentor('academic_mentor', 'Academic Mentors');

  const ReferralSource(this.code, this.label);
  final String code;
  final String label;

  static ReferralSource? fromCode(String? code) {
    for (final r in values) {
      if (r.code == code) return r;
    }
    return null;
  }
}
