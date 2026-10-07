import 'package:equatable/equatable.dart';

class ExternalLink extends Equatable {
  final int id;
  final String url;
  final int teacherId;
  final String teacherName;
  final int subjectId;
  final String subjectName;

  const ExternalLink({
    required this.id,
    required this.url,
    required this.teacherId,
    required this.teacherName,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  List<Object?> get props => [id, url, teacherId, teacherName, subjectId, subjectName];
}
