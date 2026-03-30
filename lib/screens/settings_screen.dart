import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../services/cache_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('settings'.tr())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('dark_mode'.tr(), style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode),
                      ),
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.auto_mode),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode),
                      ),
                    ],
                    selected: {settings.themeMode},
                    onSelectionChanged: (modes) {
                      ref.read(settingsProvider.notifier).setThemeMode(modes.first);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Language
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('language'.tr(), style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: [
                      ButtonSegment(
                        value: 'en',
                        label: Text('english'.tr()),
                      ),
                      ButtonSegment(
                        value: 'ar',
                        label: Text('arabic'.tr()),
                      ),
                    ],
                    selected: {context.locale.languageCode},
                    onSelectionChanged: (locales) {
                      context.setLocale(Locale(locales.first));
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Clear cache
          Card(
            child: ListTile(
              leading: const Icon(Icons.cached),
              title: Text('cached'.tr()),
              subtitle: const Text('Clear cached service data'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  await CacheService().clearAll();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cache cleared')),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
