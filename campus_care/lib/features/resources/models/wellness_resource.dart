class ResourceCategory {
  const ResourceCategory({required this.id, required this.code, required this.name, this.icon});

  final int id;
  final String code;
  final String name;
  final String? icon;

  static const selectColumns = 'id, code, name, icon';

  factory ResourceCategory.fromJson(Map<String, dynamic> j) => ResourceCategory(
        id: (j['id'] as num).toInt(),
        code: j['code'] as String,
        name: j['name'] as String,
        icon: j['icon'] as String?,
      );
}

class WellnessResource {
  const WellnessResource({
    required this.id,
    required this.title,
    this.categoryId,
    this.summary,
    this.body,
    this.externalUrl,
    this.isFeatured = false,
  });

  final String id;
  final int? categoryId;
  final String title;
  final String? summary;
  final String? body;
  final String? externalUrl;
  final bool isFeatured;

  static const selectColumns = 'id, category_id, title, summary, body, external_url, is_featured';

  factory WellnessResource.fromJson(Map<String, dynamic> j) => WellnessResource(
        id: j['id'] as String,
        categoryId: (j['category_id'] as num?)?.toInt(),
        title: (j['title'] as String?) ?? '',
        summary: j['summary'] as String?,
        body: j['body'] as String?,
        externalUrl: j['external_url'] as String?,
        isFeatured: (j['is_featured'] as bool?) ?? false,
      );
}
