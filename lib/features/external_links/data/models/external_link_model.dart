import '../../domain/entities/external_link.dart';

class ExternalLinkModel extends ExternalLink {
  const ExternalLinkModel({
    required super.id,
    required super.url,
    required super.teacherId,
    required super.teacherName,
    required super.subjectId,
    required super.subjectName,
  });

  factory ExternalLinkModel.fromJson(Map<String, dynamic> json) {
    final teacher = json['teacher'] as Map<String, dynamic>? ?? {};
    final subject = json['subject'] as Map<String, dynamic>? ?? {};
    return ExternalLinkModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      url: json['url'] as String? ?? '',
      teacherId: (teacher['id'] as num?)?.toInt() ?? 0,
      teacherName: teacher['name'] as String? ?? '',
      subjectId: (subject['id'] as num?)?.toInt() ?? 0,
      subjectName: subject['name'] as String? ?? '',
    );
  }
}
