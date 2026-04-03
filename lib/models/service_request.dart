class ServiceRequest {
  final int id;
  final String referenceNumber;
  final int serviceId;
  final String serviceNameEn;
  final String serviceNameAr;
  final String categoryNameEn;
  final String categoryNameAr;
  final String applicantName;
  final String emiratesId;
  final String status; // pending, under_review, approved, rejected
  final String submittedAt;
  final String? estimatedCompletion;
  final String? reviewNote;

  const ServiceRequest({
    required this.id,
    required this.referenceNumber,
    required this.serviceId,
    required this.serviceNameEn,
    required this.serviceNameAr,
    required this.categoryNameEn,
    required this.categoryNameAr,
    required this.applicantName,
    required this.emiratesId,
    required this.status,
    required this.submittedAt,
    this.estimatedCompletion,
    this.reviewNote,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) => ServiceRequest(
        id: json['id'] as int,
        referenceNumber: json['reference_number'] as String,
        serviceId: json['service_id'] as int,
        serviceNameEn: json['service_name_en'] as String,
        serviceNameAr: json['service_name_ar'] as String,
        categoryNameEn: json['category_name_en'] as String,
        categoryNameAr: json['category_name_ar'] as String,
        applicantName: json['applicant_name'] as String,
        emiratesId: json['emirates_id'] as String,
        status: json['status'] as String,
        submittedAt: json['submitted_at'] as String,
        estimatedCompletion: json['estimated_completion'] as String?,
        reviewNote: json['review_note'] as String?,
      );

  String serviceName(String locale) =>
      locale == 'ar' ? serviceNameAr : serviceNameEn;
  String categoryName(String locale) =>
      locale == 'ar' ? categoryNameAr : categoryNameEn;
}
