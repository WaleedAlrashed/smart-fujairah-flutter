import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryCard extends StatelessWidget {
  final ServiceCategory category;
  final VoidCallback onTap;

  const CategoryCard({super.key, required this.category, required this.onTap});

  static const _iconMap = {
    'construction': Icons.construction,
    'landscape': Icons.landscape,
    'health_and_safety': Icons.health_and_safety,
    'map': Icons.map,
    'shield': Icons.shield,
    'cleaning_services': Icons.cleaning_services,
    'home': Icons.home,
    'badge': Icons.badge,
  };

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.languageCode;
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _iconMap[category.icon] ?? Icons.miscellaneous_services,
                size: 40,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                category.name(locale),
                style: theme.textTheme.titleSmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${category.servicesCount} ${'services'.tr()}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
