import '../../domain/entities/teacher_grades.dart';

class GradeRecordModel extends GradeRecord {
  const GradeRecordModel({
    required super.id,
    required super.studentId,
    required super.studentName,
    required super.title,
    required super.score,
    required super.maxScore,
    required super.percentage,
    super.gradedAt,
  });

  factory GradeRecordModel.fromJson(Map<String, dynamic> json) {
    final studentJson = json['student'] as Map<String, dynamic>? ?? {};
    return GradeRecordModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      studentId: (studentJson['id'] as num?)?.toInt() ?? 0,
      studentName: studentJson['name'] as String? ?? '',
      title: json['title'] as String? ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0,
      maxScore: (json['max_score'] as num?)?.toDouble() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
      gradedAt: json['graded_at'] != null ? DateTime.tryParse(json['graded_at'] as String) : null,
    );
  }
}
