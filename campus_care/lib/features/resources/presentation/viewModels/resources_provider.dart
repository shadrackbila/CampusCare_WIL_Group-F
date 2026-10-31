import 'package:flutter/foundation.dart';

import '../../../../../../core/errors/app_exception.dart';
import '../../data/resource_repository.dart';
import '../../models/wellness_resource.dart';

/// Wellness resources. The content is the same for every student, so this is not bound to a user.
class ResourcesProvider extends ChangeNotifier {
  ResourcesProvider(this._repo);

  final ResourceRepository _repo;

  List<ResourceCategory> _categories = const [];
  List<WellnessResource> _featured = const [];
  final Map<int, List<WellnessResource>> _byCategory = {};
  bool _loading = false;
  bool _loaded = false;
  String? _error;
  final Set<int> _loadingCategories = {};
  final Map<int, String> _categoryErrors = {};
  bool _disposed = false;

  List<ResourceCategory> get categories => _categories;
  List<WellnessResource> get featured => _featured;
  bool get loading => _loading;
  bool get loaded => _loaded;
  String? get error => _error;

  ResourceCategory? categoryById(int id) {
    for (final c in _categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  List<WellnessResource>? inCategory(int id) => _byCategory[id];
  bool categoryLoading(int id) => _loadingCategories.contains(id);
  String? categoryError(int id) => _categoryErrors[id];

  WellnessResource? byId(String id) {
    for (final r in _featured) {
      if (r.id == id) return r;
    }
    for (final list in _byCategory.values) {
      for (final r in list) {
        if (r.id == id) return r;
      }
    }
    return null;
  }

  Future<void> loadHub({bool silent = false}) async {
    if (!silent) {
      _loading = true;
      _error = null;
      _notify();
    }
    try {
      final results = await Future.wait<Object>([
        _repo.fetchCategories(),
        _repo.fetchResources(featuredOnly: true),
      ]);
      _categories = results[0] as List<ResourceCategory>;
      _featured = results[1] as List<WellnessResource>;
      _loaded = true;
      _error = null;
    } on AppException catch (e) {
      _error = e.message;
    } finally {
      _loading = false;
      _notify();
    }
  }

  Future<void> loadCategory(int id) async {
    _loadingCategories.add(id);
    _categoryErrors.remove(id);
    _notify();
    try {
      _byCategory[id] = await _repo.fetchResources(categoryId: id);
    } on AppException catch (e) {
      _categoryErrors[id] = e.message;
    } finally {
      _loadingCategories.remove(id);
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
