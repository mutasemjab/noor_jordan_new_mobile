import 'package:equatable/equatable.dart';

class SubjectVideo extends Equatable {
  final int id;
  final String title;
  final String youtubeUrl;
  final String youtubeId;
  final String thumbnail;
  final int orderIndex;

  const SubjectVideo({
    required this.id,
    required this.title,
    required this.youtubeUrl,
    required this.youtubeId,
    required this.thumbnail,
    required this.orderIndex,
  });

  @override
  List<Object?> get props => [id, title, youtubeUrl, youtubeId, thumbnail, orderIndex];
}
