import '../../domain/entities/teacher_grades.dart';

class GradeClassModel extends GradeClass {
  const GradeClassModel({required super.classId, required super.className, required super.subject});

  factory GradeClassModel.fromJson(Map<String, dynamic> json) {
    return GradeClassModel(
      classId: json['id'] as int,
      className: json['name'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
    );
  }
}

class GradeExamTypeModel extends GradeExamType {
  const GradeExamTypeModel({required super.id, required super.name, required super.maxScore});

  factory GradeExamTypeModel.fromJson(Map<String, dynamic> json) {
    return GradeExamTypeModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      maxScore: ((json['max_score'] ?? json['maxScore'] ?? 100) as num).toDouble(),
    );
  }
}

class StudentGradeEntryModel extends StudentGradeEntry {
  const StudentGradeEntryModel({required super.studentId, required super.studentName, super.score});

  factory StudentGradeEntryModel.fromJson(Map<String, dynamic> json) {
    return StudentGradeEntryModel(
      studentId: json['student_id'] as int? ?? json['id'] as int,
      studentName: json['name'] as String? ?? '',
      score: json['score'] != null ? (json['score'] as num).toDouble() : null,
    );
  }
}
