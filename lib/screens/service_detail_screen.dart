import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/service.dart';
import '../providers/service_providers.dart';

final serviceDetailProvider =
    FutureProvider.family<MunicipalityService, int>((ref, serviceId) {
  return ref.read(apiServiceProvider).getServiceDetail(serviceId);
});

class ServiceDetailScreen extends ConsumerWidget {
  final int serviceId;

  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceAsync = ref.watch(serviceDetailProvider(serviceId));
    final locale = context.locale.languageCode;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('service_details'.tr())),
      body: serviceAsync.when(
        data: (service) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Service header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.miscellaneous_services,
                        size: 48, color: theme.colorScheme.primary),
                    const SizedBox(height: 12),
                    Text(service.name(locale),
                        style: theme.textTheme.headlineSmall,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(service.description(locale),
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Fee and processing time
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: theme.colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text('fee'.tr(), style: theme.textTheme.labelMedium),
                          const SizedBox(height: 4),
                          Text(
                            '${service.fee.toStringAsFixed(0)} ${'aed'.tr()}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    color: theme.colorScheme.secondaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text('processing_time'.tr(),
                              style: theme.textTheme.labelMedium),
                          const SizedBox(height: 4),
                          Text(
                            '${service.processingDays} ${'days'.tr()}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Requirements
            Text('requirements'.tr(), style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ...service.requirements(locale).map((r) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle,
                          size: 20, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(child: Text(r)),
                    ],
                  ),
                )),

            // Documents required
            if (service.requiresDocuments && service.documentTypes.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('required_documents'.tr(),
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ...service.documentTypes.map((d) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.description,
                            size: 20, color: theme.colorScheme.secondary),
                        const SizedBox(width: 8),
                        Text(d),
                      ],
                    ),
                  )),
            ],

            const SizedBox(height: 32),

            // Apply button
            FilledButton.icon(
              onPressed: service.isAvailable
                  ? () => context.push('/request/${service.id}')
                  : null,
              icon: const Icon(Icons.send),
              label: Text('apply_now'.tr()),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('error_occurred'.tr())),
      ),
    );
  }
}
