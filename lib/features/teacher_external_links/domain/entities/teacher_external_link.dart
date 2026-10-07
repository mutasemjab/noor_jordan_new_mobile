import 'package:equatable/equatable.dart';
import '../../../teacher_common/domain/entities/teacher_subject.dart';

class TeacherExternalLink extends Equatable {
  final int id;
  final String url;
  final TeacherSubject? subject;
  final int? classId;
  final String? className;

  const TeacherExternalLink({
    required this.id,
    required this.url,
    this.subject,
    this.classId,
    this.className,
  });

  @override
  List<Object?> get props => [id, url, subject, classId, className];
}
