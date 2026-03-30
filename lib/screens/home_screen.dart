import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/categories_provider.dart';
import '../widgets/category_card.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/announcement_card.dart';
import '../providers/service_providers.dart';
import '../models/announcement.dart';

final announcementsProvider = FutureProvider<List<Announcement>>((ref) {
  return ref.read(apiServiceProvider).getAnnouncements();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final announcementsAsync = ref.watch(announcementsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('app_name'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(categoriesProvider.notifier).refresh(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(categoriesProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Announcements
            announcementsAsync.when(
              data: (announcements) => announcements.isEmpty
                  ? const SizedBox.shrink()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('announcements'.tr(),
                            style: theme.textTheme.titleLarge),
                        const SizedBox(height: 8),
                        ...announcements.map((a) => AnnouncementCard(announcement: a)),
                        const SizedBox(height: 24),
                      ],
                    ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // Categories header
            Text('categories'.tr(), style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),

            // Categories grid
            categoriesAsync.when(
              data: (categories) => GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return CategoryCard(
                    category: cat,
                    onTap: () => context.go('/category/${cat.id}'),
                  );
                },
              ),
              loading: () => const ShimmerLoading(isGrid: true),
              error: (error, _) => Center(
                child: Column(
                  children: [
                    Text('error_occurred'.tr()),
                    const SizedBox(height: 8),
                    Text(error.toString(), style: theme.textTheme.bodySmall),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () =>
                          ref.read(categoriesProvider.notifier).refresh(),
                      icon: const Icon(Icons.refresh),
                      label: Text('retry'.tr()),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
