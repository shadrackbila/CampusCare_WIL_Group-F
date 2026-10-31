/// The student's most recent consent record.
class ConsentStatus {
  const ConsentStatus({required this.version, required this.acceptedAt, this.withdrawnAt});

  final String version;
  final DateTime acceptedAt;
  final DateTime? withdrawnAt;

  bool get isActive => withdrawnAt == null;

  static const selectColumns = 'consent_version, accepted_at, withdrawn_at';

  factory ConsentStatus.fromJson(Map<String, dynamic> j) => ConsentStatus(
        version: (j['consent_version'] as String?) ?? '',
        acceptedAt: DateTime.parse(j['accepted_at'] as String),
        withdrawnAt:
            j['withdrawn_at'] == null ? null : DateTime.parse(j['withdrawn_at'] as String),
      );
}
