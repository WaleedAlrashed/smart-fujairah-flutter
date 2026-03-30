import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/categories_provider.dart';
import '../providers/services_provider.dart';
import '../widgets/service_tile.dart';
import '../widgets/shimmer_loading.dart';

class CategoryServicesScreen extends ConsumerWidget {
  final int categoryId;

  const CategoryServicesScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(categoryServicesProvider(categoryId));
    final categoriesAsync = ref.watch(categoriesProvider);
    final locale = context.locale.languageCode;

    final categoryName = categoriesAsync.whenOrNull(
      data: (cats) => cats
          .where((c) => c.id == categoryId)
          .firstOrNull
          ?.name(locale),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName ?? 'services'.tr()),
      ),
      body: servicesAsync.when(
        data: (services) => services.isEmpty
            ? Center(child: Text('no_results'.tr()))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return ServiceTile(
                    service: service,
                    onTap: service.isAvailable
                        ? () => context.go(
                            '/category/$categoryId/service/${service.id}')
                        : () {},
                  );
                },
              ),
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: ShimmerLoading(),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('error_occurred'.tr()),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () => ref
                    .read(categoryServicesProvider(categoryId).notifier)
                    .refresh(),
                icon: const Icon(Icons.refresh),
                label: Text('retry'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
