import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/errors/app_exception.dart';
import '../models/wellness_resource.dart';

abstract class ResourceRepository {
  Future<List<ResourceCategory>> fetchCategories();
  Future<List<WellnessResource>> fetchResources({
    int? categoryId,
    bool featuredOnly = false,
  });
}

class SupabaseResourceRepository implements ResourceRepository {
  SupabaseResourceRepository(this._client);

  final SupabaseClient _client;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e, s) {
      throw AppException.from(e, s);
    }
  }

  @override
  Future<List<ResourceCategory>> fetchCategories() => _guard(() async {
    final rows = await _client
        .from('resource_categories')
        .select(ResourceCategory.selectColumns)
        .order('sort_order');
    return [for (final r in rows) ResourceCategory.fromJson(r)];
  });

  @override
  Future<List<WellnessResource>> fetchResources({
    int? categoryId,
    bool featuredOnly = false,
  }) => _guard(() async {
    var q = _client
        .from('resources')
        .select(WellnessResource.selectColumns)
        .eq('is_published', true);
    if (categoryId != null) q = q.eq('category_id', categoryId);
    if (featuredOnly) q = q.eq('is_featured', true);
    final rows = await q.order('created_at', ascending: false).limit(100);
    return [for (final r in rows) WellnessResource.fromJson(r)];
  });
}
