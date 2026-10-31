class PresentingConcern {
  const PresentingConcern({
    required this.id,
    required this.code,
    required this.label,
    required this.isHighRisk,
  });

  final int id;
  final String code;
  final String label;

  /// Used by the backend to alert staff. Never shown to the student.
  final bool isHighRisk;

  factory PresentingConcern.fromRow(Map<String, dynamic> j) => PresentingConcern(
        id: (j['id'] as num).toInt(),
        code: j['code'] as String,
        label: j['label'] as String,
        isHighRisk: (j['is_high_risk'] as bool?) ?? false,
      );
}
