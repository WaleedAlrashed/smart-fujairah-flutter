class MunicipalityService {
  final int id;
  final int categoryId;
  final String nameEn;
  final String nameAr;
  final String descriptionEn;
  final String descriptionAr;
  final List<String> requirementsEn;
  final List<String> requirementsAr;
  final double fee;
  final int processingDays;
  final bool requiresDocuments;
  final List<String> documentTypes;
  final String status;
  final String icon;

  const MunicipalityService({
    required this.id,
    required this.categoryId,
    required this.nameEn,
    required this.nameAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.requirementsEn,
    required this.requirementsAr,
    required this.fee,
    required this.processingDays,
    required this.requiresDocuments,
    this.documentTypes = const [],
    required this.status,
    required this.icon,
  });

  factory MunicipalityService.fromJson(Map<String, dynamic> json) => MunicipalityService(
    id: json['id'] as int,
    categoryId: json['category_id'] as int,
    nameEn: json['name_en'] as String,
    nameAr: json['name_ar'] as String,
    descriptionEn: json['description_en'] as String,
    descriptionAr: json['description_ar'] as String,
    requirementsEn: List<String>.from(json['requirements_en'] as List),
    requirementsAr: List<String>.from(json['requirements_ar'] as List),
    fee: (json['fee'] as num).toDouble(),
    processingDays: json['processing_days'] as int,
    requiresDocuments: json['requires_documents'] as bool,
    documentTypes: json['document_types'] != null
        ? List<String>.from(json['document_types'] as List)
        : const [],
    status: json['status'] as String,
    icon: json['icon'] as String,
  );

  String name(String locale) => locale == 'ar' ? nameAr : nameEn;
  String description(String locale) => locale == 'ar' ? descriptionAr : descriptionEn;
  List<String> requirements(String locale) => locale == 'ar' ? requirementsAr : requirementsEn;
  bool get isAvailable => status == 'available';
}
