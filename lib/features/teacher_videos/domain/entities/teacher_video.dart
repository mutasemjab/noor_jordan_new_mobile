import 'package:equatable/equatable.dart';
import '../../../teacher_common/domain/entities/teacher_subject.dart';

class TeacherVideo extends Equatable {
  final int id;
  final String title;
  final String youtubeUrl;
  final String youtubeId;
  final TeacherSubject? subject;

  const TeacherVideo({
    required this.id,
    required this.title,
    required this.youtubeUrl,
    required this.youtubeId,
    this.subject,
  });

  @override
  List<Object?> get props => [id, title, youtubeUrl, youtubeId, subject];
}
