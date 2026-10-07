import '../../domain/entities/announcement.dart';

class AnnouncementModel extends Announcement {
  const AnnouncementModel({
    required super.id,
    required super.title,
    required super.body,
    super.imageUrl,
    super.pdfUrl,
    required super.publishedAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) =>
      AnnouncementModel(
        id: json['id'] as int,
        title: (json['title'] ?? '') as String,
        body: (json['body'] ?? '') as String,
        imageUrl: json['image'] as String?,
        pdfUrl: json['pdf_url'] as String?,
        publishedAt: (json['published_at'] ?? json['created_at'] ?? '') as String,
      );
}
