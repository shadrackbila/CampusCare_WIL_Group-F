/// A bookable "type of support" (row of `services`).
class SupportService {
  const SupportService({required this.id, required this.name, this.description});

  final String id;
  final String name;
  final String? description;

  static const selectColumns = 'id, name, description';

  factory SupportService.fromJson(Map<String, dynamic> j) => SupportService(
        id: j['id'] as String,
        name: j['name'] as String,
        description: j['description'] as String?,
      );

  /// The Figma flow has no service picker and shows "Counseling", so default to the
  /// counselling service when there is one, otherwise the first.
  static SupportService? defaultOf(List<SupportService> all) {
    if (all.isEmpty) return null;
    for (final s in all) {
      if (s.name.toLowerCase().contains('counsel')) return s;
    }
    return all.first;
  }
}
