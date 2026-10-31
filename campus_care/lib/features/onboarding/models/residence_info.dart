class ResidenceInfo {
  const ResidenceInfo({
    this.residenceType,
    this.residenceName = '',
    this.roomNumber = '',
    this.address = '',
    this.city = '',
    this.postalCode = '',
    this.province,
  });

  /// 'cut' or 'private'
  final String? residenceType;
  final String residenceName;
  final String roomNumber;
  final String address;
  final String city;
  final String postalCode;
  final String? province;

  bool get isCut => residenceType == 'cut';
  bool get isPrivate => residenceType == 'private';

  factory ResidenceInfo.fromRow(Map<String, dynamic> j) => ResidenceInfo(
        residenceType: j['residence_type'] as String?,
        residenceName: (j['residence_name'] as String?) ?? '',
        roomNumber: (j['room_number'] as String?) ?? '',
        address: (j['address'] as String?) ?? '',
        city: (j['city'] as String?) ?? '',
        postalCode: (j['postal_code'] as String?) ?? '',
        province: j['province'] as String?,
      );

  String? _opt(String v) => v.trim().isEmpty ? null : v.trim();

  /// Only the fields relevant to the chosen type are sent; the others are cleared.
  Map<String, dynamic> toUpsert(String studentId) => {
        'student_id': studentId,
        'residence_type': residenceType,
        'residence_name': isCut ? _opt(residenceName) : null,
        'room_number': isCut ? _opt(roomNumber) : null,
        'address': isPrivate ? _opt(address) : null,
        'city': isPrivate ? _opt(city) : null,
        'postal_code': isPrivate ? _opt(postalCode) : null,
        'province': isPrivate ? province : null,
      };

  bool get isComplete {
    if (isCut) return residenceName.trim().isNotEmpty;
    if (isPrivate) {
      return address.trim().isNotEmpty &&
          city.trim().isNotEmpty &&
          postalCode.trim().isNotEmpty &&
          province != null;
    }
    return false;
  }
}
