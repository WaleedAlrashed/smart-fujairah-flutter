class ServiceCategory {
  final int id;
  final String nameEn;
  final String nameAr;
  final String icon;
  final int servicesCount;

  const ServiceCategory({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.icon,
    required this.servicesCount,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) => ServiceCategory(
    id: json['id'] as int,
    nameEn: json['name_en'] as String,
    nameAr: json['name_ar'] as String,
    icon: json['icon'] as String,
    servicesCount: json['services_count'] as int,
  );

  String name(String locale) => locale == 'ar' ? nameAr : nameEn;
}
