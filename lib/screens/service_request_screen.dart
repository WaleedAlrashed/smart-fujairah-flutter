import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/request_provider.dart';
import '../widgets/file_upload_widget.dart';

class ServiceRequestScreen extends ConsumerStatefulWidget {
  final int serviceId;

  const ServiceRequestScreen({super.key, required this.serviceId});

  @override
  ConsumerState<ServiceRequestScreen> createState() =>
      _ServiceRequestScreenState();
}

class _ServiceRequestScreenState extends ConsumerState<ServiceRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _eidController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _eidController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _validateEmiratesId(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final regex = RegExp(r'^784-\d{4}-\d{7}-\d$');
    if (!regex.hasMatch(value)) return 'Format: 784-YYYY-NNNNNNN-C';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final regex = RegExp(r'^(05\d{8}|\+9715\d{8})$');
    if (!regex.hasMatch(value)) return 'Format: 05XXXXXXXX';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final requestState = ref.watch(serviceRequestProvider);
    final theme = Theme.of(context);

    // Show success dialog
    if (requestState.referenceNumber != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSuccessDialog(context, requestState.referenceNumber!);
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text('submit_request'.tr())),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('personal_info'.tr(), style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),

            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'full_name'.tr(),
                prefixIcon: const Icon(Icons.person),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _eidController,
              decoration: InputDecoration(
                labelText: 'emirates_id'.tr(),
                hintText: '784-YYYY-NNNNNNN-C',
                prefixIcon: const Icon(Icons.credit_card),
              ),
              validator: _validateEmiratesId,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'phone'.tr(),
                hintText: '05XXXXXXXX',
                prefixIcon: const Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: _validatePhone,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'email'.tr(),
                prefixIcon: const Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (!v.contains('@')) return 'Invalid email';
                return null;
              },
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'notes'.tr(),
                prefixIcon: const Icon(Icons.notes),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // File upload section
            const FileUploadWidget(),
            const SizedBox(height: 24),

            // Error message
            if (requestState.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  requestState.error!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),

            // Submit button
            FilledButton.icon(
              onPressed: requestState.isSubmitting ? null : _submit,
              icon: requestState.isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send),
              label: Text('submit_request'.tr()),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    ref.read(serviceRequestProvider.notifier).submitRequest(
      serviceId: widget.serviceId,
      fullName: _nameController.text,
      emiratesId: _eidController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );
  }

  void _showSuccessDialog(BuildContext context, String refNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.check_circle, size: 48,
            color: Theme.of(context).colorScheme.primary),
        title: Text('request_submitted'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('reference_number'.tr()),
            const SizedBox(height: 8),
            SelectableText(
              refNumber,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              ref.read(serviceRequestProvider.notifier).reset();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
