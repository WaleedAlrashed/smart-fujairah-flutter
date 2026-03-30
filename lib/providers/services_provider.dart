import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service.dart';
import 'service_providers.dart';

class CategoryServicesNotifier extends AsyncNotifier<List<MunicipalityService>> {
  final int categoryId;

  CategoryServicesNotifier(this.categoryId);

  @override
  Future<List<MunicipalityService>> build() async {
    return _fetchServices(categoryId);
  }

  Future<List<MunicipalityService>> _fetchServices(int categoryId) async {
    final api = ref.read(apiServiceProvider);
    final cache = ref.read(cacheServiceProvider);

    final cacheKey = 'services_$categoryId';
    final cached = await cache.get<List<dynamic>>(cacheKey);
    if (cached != null) {
      return cached
          .map((e) => MunicipalityService.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    final services = await api.getCategoryServices(categoryId);

    // Cache raw response data (re-serialize to JSON-compatible map)
    await cache.put(cacheKey, services.map(_serviceToJson).toList());

    return services;
  }

  Map<String, dynamic> _serviceToJson(MunicipalityService s) => {
    'id': s.id,
    'category_id': s.categoryId,
    'name_en': s.nameEn,
    'name_ar': s.nameAr,
    'description_en': s.descriptionEn,
    'description_ar': s.descriptionAr,
    'requirements_en': s.requirementsEn,
    'requirements_ar': s.requirementsAr,
    'fee': s.fee,
    'processing_days': s.processingDays,
    'requires_documents': s.requiresDocuments,
    'document_types': s.documentTypes,
    'status': s.status,
    'icon': s.icon,
  };

  Future<void> refresh() async {
    final cache = ref.read(cacheServiceProvider);
    await cache.remove('services_$categoryId');
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchServices(categoryId));
  }
}

final categoryServicesProvider = AsyncNotifierProvider.family<
    CategoryServicesNotifier, List<MunicipalityService>, int>(
  (categoryId) => CategoryServicesNotifier(categoryId),
);
