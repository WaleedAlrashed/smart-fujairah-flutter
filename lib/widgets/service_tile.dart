import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../models/service.dart';

class ServiceTile extends StatelessWidget {
  final MunicipalityService service;
  final VoidCallback onTap;

  const ServiceTile({super.key, required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.languageCode;
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(Icons.miscellaneous_services,
              color: theme.colorScheme.onPrimaryContainer),
        ),
        title: Text(service.name(locale)),
        subtitle: Text(
          '${service.fee.toStringAsFixed(0)} ${'aed'.tr()} · ${service.processingDays} ${'days'.tr()}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: service.isAvailable
            ? Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.primary)
            : Chip(
                label: Text('coming_soon'.tr(),
                    style: const TextStyle(fontSize: 10)),
                padding: EdgeInsets.zero,
              ),
      ),
    );
  }
}
