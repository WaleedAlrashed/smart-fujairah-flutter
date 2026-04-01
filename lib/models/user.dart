class AppUser {
  final int id;
  final String nameEn;
  final String nameAr;
  final String emiratesId;
  final String email;
  final String phone;
  final String role;

  const AppUser({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.emiratesId,
    required this.email,
    required this.phone,
    required this.role,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as int,
    nameEn: json['name_en'] as String,
    nameAr: json['name_ar'] as String,
    emiratesId: json['emirates_id'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String,
    role: json['role'] as String,
  );

  String name(String locale) => locale == 'ar' ? nameAr : nameEn;
}
