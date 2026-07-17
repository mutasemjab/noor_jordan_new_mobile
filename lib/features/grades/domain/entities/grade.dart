import 'package:equatable/equatable.dart';

class GradeEntry extends Equatable {
  final int id;
  final String title;
  final double score;
  final double maxScore;
  final double percentage;
  final String gradedAt;

  const GradeEntry({
    required this.id,
    required this.title,
    required this.score,
    required this.maxScore,
    required this.percentage,
    required this.gradedAt,
  });

  @override
  List<Object?> get props => [id, title, score, maxScore, percentage, gradedAt];
}

class SubjectGrades extends Equatable {
  final int subjectId;
  final String subjectName;
  final String? subjectIcon;
  final String? colorClass;
  final List<GradeEntry> grades;
  final double average;

  const SubjectGrades({
    required this.subjectId,
    required this.subjectName,
    this.subjectIcon,
    this.colorClass,
    required this.grades,
    required this.average,
  });

  @override
  List<Object?> get props =>
      [subjectId, subjectName, subjectIcon, colorClass, grades, average];
}
