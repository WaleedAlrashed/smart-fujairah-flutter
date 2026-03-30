import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/request_provider.dart';

class FileUploadWidget extends ConsumerWidget {
  const FileUploadWidget({super.key});

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestState = ref.watch(serviceRequestProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('required_documents'.tr(), style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text('supported_formats'.tr(), style: theme.textTheme.bodySmall),
        const SizedBox(height: 12),

        // Upload button
        OutlinedButton.icon(
          onPressed: requestState.isUploading
              ? null
              : () => _pickAndUpload(context, ref),
          icon: requestState.isUploading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.upload_file),
          label: Text(requestState.isUploading
              ? 'loading'.tr()
              : 'upload_document'.tr()),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        const SizedBox(height: 12),

        // Uploaded files list
        ...requestState.uploadedFiles.map((file) => Card(
          child: ListTile(
            leading: const Icon(Icons.insert_drive_file),
            title: Text(file.fileName, overflow: TextOverflow.ellipsis),
            subtitle: Text(_formatSize(file.fileSize)),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () =>
                  ref.read(serviceRequestProvider.notifier).removeFile(file.fileId),
            ),
          ),
        )),
      ],
    );
  }

  Future<void> _pickAndUpload(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null) return;

    // Check file size (max 5MB)
    if (file.bytes!.length > 5 * 1024 * 1024) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File too large. Maximum 5MB.')),
        );
      }
      return;
    }

    ref.read(serviceRequestProvider.notifier).uploadFile(
      fileName: file.name,
      fileBytes: file.bytes!,
    );
  }
}
