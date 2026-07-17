import '../../domain/entities/subject_video.dart';

class SubjectVideoModel extends SubjectVideo {
  const SubjectVideoModel({
    required super.id,
    required super.title,
    required super.youtubeUrl,
    required super.youtubeId,
    required super.thumbnail,
    required super.orderIndex,
  });

  factory SubjectVideoModel.fromJson(Map<String, dynamic> json) {
    return SubjectVideoModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      youtubeUrl: json['youtube_url'] as String? ?? '',
      youtubeId: json['youtube_id'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
      orderIndex: json['order_index'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'youtube_url': youtubeUrl,
      'youtube_id': youtubeId,
      'thumbnail': thumbnail,
      'order_index': orderIndex,
    };
  }
}
