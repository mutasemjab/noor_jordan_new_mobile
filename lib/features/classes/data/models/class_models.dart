import '../../domain/entities/school_class.dart';

class SchoolClassModel extends SchoolClass {
  const SchoolClassModel({
    required super.id,
    required super.name,
    required super.grade,
    required super.section,
    required super.studentCount,
    required super.subject,
  });

  factory SchoolClassModel.fromJson(Map<String, dynamic> json) {
    return SchoolClassModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      grade: json['grade'] as String? ?? '',
      section: json['section'] as String? ?? '',
      studentCount: (json['student_count'] ?? json['studentCount'] ?? 0) as int,
      subject: json['subject'] as String? ?? '',
    );
  }
}

class ClassStudentModel extends ClassStudent {
  const ClassStudentModel({
    required super.id,
    required super.name,
    required super.studentNumber,
    super.avatarUrl,
  });

  factory ClassStudentModel.fromJson(Map<String, dynamic> json) {
    return ClassStudentModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      studentNumber: (json['student_number'] ?? json['studentNumber'] ?? '') as String,
      avatarUrl: json['avatar'] as String?,
    );
  }
}
