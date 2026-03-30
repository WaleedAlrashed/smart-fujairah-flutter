import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import 'service_providers.dart';

class CategoriesNotifier extends AsyncNotifier<List<ServiceCategory>> {
  @override
  Future<List<ServiceCategory>> build() async {
    return _fetchCategories();
  }

  Future<List<ServiceCategory>> _fetchCategories() async {
    final api = ref.read(apiServiceProvider);
    final cache = ref.read(cacheServiceProvider);

    // Try cache first
    final cached = await cache.get<List<dynamic>>('categories');
    if (cached != null) {
      return cached
          .map((e) => ServiceCategory.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    // Fetch from API
    final categories = await api.getCategories();

    // Cache the raw JSON
    await cache.put(
      'categories',
      categories.map((c) => {
        'id': c.id,
        'name_en': c.nameEn,
        'name_ar': c.nameAr,
        'icon': c.icon,
        'services_count': c.servicesCount,
      }).toList(),
    );

    return categories;
  }

  Future<void> refresh() async {
    final cache = ref.read(cacheServiceProvider);
    await cache.remove('categories');
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchCategories);
  }
}

final categoriesProvider =
    AsyncNotifierProvider<CategoriesNotifier, List<ServiceCategory>>(
  CategoriesNotifier.new,
);
