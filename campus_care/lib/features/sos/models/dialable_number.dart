/// Keeps only what a phone dialler needs: digits and a leading "+". Returns null if nothing usable.
String? dialableNumber(String? raw) {
  if (raw == null) return null;
  final trimmed = raw.trim();
  final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return null;
  return trimmed.startsWith('+') ? '+$digits' : digits;
}
