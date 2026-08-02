import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../teacher_common/domain/entities/teacher_subject.dart';
import '../../domain/entities/teacher_video.dart';

class TeacherVideoModel extends TeacherVideo {
  const TeacherVideoModel({
    required super.id,
    required super.title,
    required super.youtubeUrl,
    required super.youtubeId,
    super.subject,
  });

  factory TeacherVideoModel.fromJson(Map<String, dynamic> json) {
    final subjectJson = json['subject'] as Map<String, dynamic>?;
    final youtubeUrl = json['youtube_url'] as String? ?? '';
    final youtubeId = json['youtube_id'] as String? ?? YoutubePlayer.convertUrlToId(youtubeUrl) ?? '';
    return TeacherVideoModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      youtubeUrl: youtubeUrl,
      youtubeId: youtubeId,
      subject: subjectJson != null
          ? TeacherSubject(id: (subjectJson['id'] as num?)?.toInt() ?? 0, name: subjectJson['name'] as String? ?? '')
          : null,
    );
  }
}
