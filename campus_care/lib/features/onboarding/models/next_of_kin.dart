class NextOfKin {
  const NextOfKin({
    this.fullName = '',
    this.relationship = '',
    this.cellNumber = '',
    this.alternativeNumber = '',
    this.email = '',
    this.residentialAddress = '',
  });

  final String fullName;
  final String relationship;
  final String cellNumber;
  final String alternativeNumber;
  final String email;
  final String residentialAddress;

  factory NextOfKin.fromRow(Map<String, dynamic> j) => NextOfKin(
        fullName: (j['full_name'] as String?) ?? '',
        relationship: (j['relationship'] as String?) ?? '',
        cellNumber: (j['cell_number'] as String?) ?? '',
        alternativeNumber: (j['alternative_number'] as String?) ?? '',
        email: (j['email'] as String?) ?? '',
        residentialAddress: (j['residential_address'] as String?) ?? '',
      );

  String? _opt(String v) => v.trim().isEmpty ? null : v.trim();

  Map<String, dynamic> toUpsert(String studentId) => {
        'student_id': studentId,
        'full_name': fullName.trim(),
        'relationship': relationship.trim(),
        'cell_number': cellNumber.trim(),
        'alternative_number': _opt(alternativeNumber),
        'email': _opt(email),
        'residential_address': _opt(residentialAddress),
      };

  bool get isComplete =>
      fullName.trim().isNotEmpty &&
      relationship.trim().isNotEmpty &&
      cellNumber.trim().isNotEmpty;
}
