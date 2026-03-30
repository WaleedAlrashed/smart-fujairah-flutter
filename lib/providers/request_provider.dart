import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'service_providers.dart';

class ServiceRequestState {
  final bool isSubmitting;
  final bool isUploading;
  final String? referenceNumber;
  final String? error;
  final List<UploadedFile> uploadedFiles;

  const ServiceRequestState({
    this.isSubmitting = false,
    this.isUploading = false,
    this.referenceNumber,
    this.error,
    this.uploadedFiles = const [],
  });

  ServiceRequestState copyWith({
    bool? isSubmitting,
    bool? isUploading,
    String? referenceNumber,
    String? error,
    List<UploadedFile>? uploadedFiles,
  }) => ServiceRequestState(
    isSubmitting: isSubmitting ?? this.isSubmitting,
    isUploading: isUploading ?? this.isUploading,
    referenceNumber: referenceNumber ?? this.referenceNumber,
    error: error,
    uploadedFiles: uploadedFiles ?? this.uploadedFiles,
  );
}

class UploadedFile {
  final String fileId;
  final String fileName;
  final int fileSize;

  const UploadedFile({
    required this.fileId,
    required this.fileName,
    required this.fileSize,
  });
}

class ServiceRequestNotifier extends Notifier<ServiceRequestState> {
  @override
  ServiceRequestState build() => const ServiceRequestState();

  Future<void> submitRequest({
    required int serviceId,
    required String fullName,
    required String emiratesId,
    required String phone,
    required String email,
    String? notes,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final api = ref.read(apiServiceProvider);
      final result = await api.submitRequest(
        serviceId: serviceId,
        fullName: fullName,
        emiratesId: emiratesId,
        phone: phone,
        email: email,
        notes: notes,
      );
      state = state.copyWith(
        isSubmitting: false,
        referenceNumber: result['reference_number'] as String,
      );
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
    }
  }

  Future<void> uploadFile({
    required String fileName,
    required List<int> fileBytes,
  }) async {
    state = state.copyWith(isUploading: true, error: null);
    try {
      final api = ref.read(apiServiceProvider);
      final result = await api.uploadDocument(
        fileName: fileName,
        fileBytes: fileBytes,
      );
      final uploaded = UploadedFile(
        fileId: result['file_id'] as String,
        fileName: fileName,
        fileSize: fileBytes.length,
      );
      state = state.copyWith(
        isUploading: false,
        uploadedFiles: [...state.uploadedFiles, uploaded],
      );
    } catch (e) {
      state = state.copyWith(isUploading: false, error: e.toString());
    }
  }

  void removeFile(String fileId) {
    state = state.copyWith(
      uploadedFiles: state.uploadedFiles.where((f) => f.fileId != fileId).toList(),
    );
  }

  void reset() {
    state = const ServiceRequestState();
  }
}

final serviceRequestProvider =
    NotifierProvider<ServiceRequestNotifier, ServiceRequestState>(
  ServiceRequestNotifier.new,
);
