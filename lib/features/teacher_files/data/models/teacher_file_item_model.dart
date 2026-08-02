import '../../../teacher_common/domain/entities/teacher_subject.dart';
import '../../domain/entities/teacher_file_item.dart';

class TeacherFileItemModel extends TeacherFileItem {
  const TeacherFileItemModel({
    required super.id,
    required super.title,
    super.year,
    super.pages,
    super.fileSize,
    required super.pdfUrl,
    super.subject,
    super.schoolClass,
  });

  factory TeacherFileItemModel.fromJson(Map<String, dynamic> json) {
    final subjectJson = json['subject'] as Map<String, dynamic>?;
    final classJson = json['class'] as Map<String, dynamic>?;
    return TeacherFileItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? json['title_ar'] as String? ?? '',
      year: (json['year'] as num?)?.toInt(),
      pages: (json['pages'] as num?)?.toInt(),
      fileSize: (json['file_size'] as num?)?.toDouble(),
      pdfUrl: json['pdf_url'] as String? ?? '',
      subject: subjectJson != null
          ? TeacherSubject(id: (subjectJson['id'] as num?)?.toInt() ?? 0, name: subjectJson['name'] as String? ?? '')
          : null,
      schoolClass: classJson != null
          ? TeacherClassRef(id: (classJson['id'] as num?)?.toInt() ?? 0, name: classJson['name'] as String? ?? '')
          : null,
    );
  }
}
