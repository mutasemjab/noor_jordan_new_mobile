import 'package:equatable/equatable.dart';

class GradeClass extends Equatable {
  final int classId;
  final String className;
  final String subject;

  const GradeClass({required this.classId, required this.className, required this.subject});

  @override
  List<Object?> get props => [classId, className, subject];
}

class GradeExamType extends Equatable {
  final int id;
  final String name;
  final double maxScore;

  const GradeExamType({required this.id, required this.name, required this.maxScore});

  @override
  List<Object?> get props => [id, name, maxScore];
}

class StudentGradeEntry extends Equatable {
  final int studentId;
  final String studentName;
  final double? score;

  const StudentGradeEntry({
    required this.studentId,
    required this.studentName,
    this.score,
  });

  StudentGradeEntry copyWith({double? score}) {
    return StudentGradeEntry(studentId: studentId, studentName: studentName, score: score ?? this.score);
  }

  @override
  List<Object?> get props => [studentId, studentName, score];
}
