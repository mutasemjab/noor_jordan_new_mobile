import 'package:equatable/equatable.dart';

class SchoolClass extends Equatable {
  final int id;
  final String name;
  final String grade;
  final String section;
  final int studentCount;
  final String subject;

  const SchoolClass({
    required this.id,
    required this.name,
    required this.grade,
    required this.section,
    required this.studentCount,
    required this.subject,
  });

  @override
  List<Object?> get props => [id, name, grade, section, studentCount, subject];
}

class ClassStudent extends Equatable {
  final int id;
  final String name;
  final String studentNumber;
  final String? avatarUrl;

  const ClassStudent({
    required this.id,
    required this.name,
    required this.studentNumber,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, name, studentNumber, avatarUrl];
}
