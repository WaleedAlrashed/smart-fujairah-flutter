import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_request.dart';
import '../providers/requests_provider.dart';

class MyRequestsScreen extends ConsumerWidget {
  const MyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(myRequestsProvider);
    final theme = Theme.of(context);
    final locale = context.locale.languageCode;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('my_requests'.tr()),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'all'.tr()),
              Tab(text: 'pending'.tr()),
              Tab(text: 'approved'.tr()),
              Tab(text: 'rejected'.tr()),
            ],
          ),
        ),
        body: requestsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('error_occurred'.tr()),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: () => ref.read(myRequestsProvider.notifier).refresh(),
                  child: Text('retry'.tr()),
                ),
              ],
            ),
          ),
          data: (requests) => TabBarView(
            children: [
              _RequestList(
                requests: requests,
                locale: locale,
                onRefresh: () => ref.read(myRequestsProvider.notifier).refresh(),
              ),
              _RequestList(
                requests: requests
                    .where((r) =>
                        r.status == 'pending' || r.status == 'under_review')
                    .toList(),
                locale: locale,
                emptyLabel: 'no_pending_requests',
                onRefresh: () => ref.read(myRequestsProvider.notifier).refresh(),
              ),
              _RequestList(
                requests: requests
                    .where((r) => r.status == 'approved')
                    .toList(),
                locale: locale,
                emptyLabel: 'no_approved_requests',
                onRefresh: () => ref.read(myRequestsProvider.notifier).refresh(),
              ),
              _RequestList(
                requests: requests
                    .where((r) => r.status == 'rejected')
                    .toList(),
                locale: locale,
                emptyLabel: 'no_rejected_requests',
                onRefresh: () => ref.read(myRequestsProvider.notifier).refresh(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestList extends StatelessWidget {
  final List<ServiceRequest> requests;
  final String locale;
  final String emptyLabel;
  final Future<void> Function() onRefresh;

  const _RequestList({
    required this.requests,
    required this.locale,
    this.emptyLabel = 'no_results',
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              emptyLabel.tr(),
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) =>
            _RequestCard(request: requests[index], locale: locale),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final ServiceRequest request;
  final String locale;

  const _RequestCard({required this.request, required this.locale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: ref number + status chip
              Row(
                children: [
                  Expanded(
                    child: Text(
                      request.referenceNumber,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  _StatusChip(status: request.status),
                ],
              ),
              const SizedBox(height: 8),

              // Service name
              Text(
                request.serviceName(locale),
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 4),

              // Category
              Text(
                request.categoryName(locale),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),

              // Footer: date + estimated
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 14, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    request.submittedAt,
                    style: theme.textTheme.bodySmall,
                  ),
                  if (request.estimatedCompletion != null) ...[
                    const Spacer(),
                    Icon(Icons.schedule,
                        size: 14, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      '${'estimated'.tr()}: ${request.estimatedCompletion}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Status
            Center(child: _StatusChip(status: request.status, large: true)),
            const SizedBox(height: 20),

            // Reference
            _DetailRow(
              icon: Icons.tag,
              label: 'reference_number'.tr(),
              value: request.referenceNumber,
            ),
            _DetailRow(
              icon: Icons.miscellaneous_services,
              label: 'services'.tr(),
              value: request.serviceName(locale),
            ),
            _DetailRow(
              icon: Icons.category,
              label: 'categories'.tr(),
              value: request.categoryName(locale),
            ),
            _DetailRow(
              icon: Icons.person,
              label: 'full_name'.tr(),
              value: request.applicantName,
            ),
            _DetailRow(
              icon: Icons.credit_card,
              label: 'emirates_id'.tr(),
              value: request.emiratesId,
            ),
            _DetailRow(
              icon: Icons.calendar_today,
              label: 'submitted'.tr(),
              value: request.submittedAt,
            ),
            if (request.estimatedCompletion != null)
              _DetailRow(
                icon: Icons.schedule,
                label: 'estimated'.tr(),
                value: request.estimatedCompletion!,
              ),
            if (request.reviewNote != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.note, size: 20,
                        color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        request.reviewNote!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Progress stepper
            const SizedBox(height: 24),
            Text('request_progress'.tr(),
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _ProgressStepper(status: request.status),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final bool large;

  const _StatusChip({required this.status, this.large = false});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      'pending' => (Colors.orange, 'pending'.tr()),
      'under_review' => (Colors.blue, 'under_review'.tr()),
      'approved' => (Colors.green, 'approved'.tr()),
      'rejected' => (Colors.red, 'rejected'.tr()),
      _ => (Colors.grey, status),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 10,
        vertical: large ? 8 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(large ? 12 : 8),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.shade700,
          fontSize: large ? 14 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                Text(value, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressStepper extends StatelessWidget {
  final String status;

  const _ProgressStepper({required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('submitted_step', Icons.send, true),
      ('under_review_step', Icons.rate_review,
          status == 'under_review' || status == 'approved'),
      ('completed_step',
          status == 'rejected' ? Icons.cancel : Icons.check_circle,
          status == 'approved' || status == 'rejected'),
    ];

    return Column(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: steps[i].$3
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade300,
                ),
                child: Icon(
                  steps[i].$2,
                  size: 18,
                  color: steps[i].$3 ? Colors.white : Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                steps[i].$1.tr(),
                style: TextStyle(
                  fontWeight:
                      steps[i].$3 ? FontWeight.w600 : FontWeight.normal,
                  color: steps[i].$3 ? null : Colors.grey,
                ),
              ),
            ],
          ),
          if (i < steps.length - 1)
            Container(
              width: 2,
              height: 24,
              margin: const EdgeInsetsDirectional.only(start: 15),
              color: steps[i + 1].$3
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade300,
            ),
        ],
      ],
    );
  }
}
