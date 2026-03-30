class Announcement {
  final int id;
  final String titleEn;
  final String titleAr;
  final String bodyEn;
  final String bodyAr;
  final String date;
  final String priority;

  const Announcement({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.bodyEn,
    required this.bodyAr,
    required this.date,
    required this.priority,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) => Announcement(
    id: json['id'] as int,
    titleEn: json['title_en'] as String,
    titleAr: json['title_ar'] as String,
    bodyEn: json['body_en'] as String,
    bodyAr: json['body_ar'] as String,
    date: json['date'] as String,
    priority: json['priority'] as String,
  );

  String title(String locale) => locale == 'ar' ? titleAr : titleEn;
  String body(String locale) => locale == 'ar' ? bodyAr : bodyEn;
}
