import '../../../teacher_common/domain/entities/teacher_subject.dart';
import '../../domain/entities/teacher_external_link.dart';

class TeacherExternalLinkModel extends TeacherExternalLink {
  const TeacherExternalLinkModel({
    required super.id,
    required super.url,
    super.subject,
    super.classId,
    super.className,
  });

  factory TeacherExternalLinkModel.fromJson(Map<String, dynamic> json) {
    final subjectJson = json['subject'] as Map<String, dynamic>?;
    final classJson = json['class'] as Map<String, dynamic>?;
    return TeacherExternalLinkModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      url: json['url'] as String? ?? '',
      subject: subjectJson != null
          ? TeacherSubject(id: (subjectJson['id'] as num?)?.toInt() ?? 0, name: subjectJson['name'] as String? ?? '')
          : null,
      classId: (classJson?['id'] as num?)?.toInt(),
      className: classJson?['name'] as String?,
    );
  }
}
