import '../../domain/entities/teacher_subject.dart';

class TeacherSubjectModel extends TeacherSubject {
  const TeacherSubjectModel({required super.id, required super.name});

  factory TeacherSubjectModel.fromJson(Map<String, dynamic> json) => TeacherSubjectModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '',
      );
}
