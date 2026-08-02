import 'package:equatable/equatable.dart';

/// One graded student, for one exam ("title"), as returned by the backend.
class GradeRecord extends Equatable {
  final int id;
  final int studentId;
  final String studentName;
  final String title;
  final double score;
  final double maxScore;
  final double percentage;
  final DateTime? gradedAt;

  const GradeRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.title,
    required this.score,
    required this.maxScore,
    required this.percentage,
    this.gradedAt,
  });

  @override
  List<Object?> get props =>
      [id, studentId, studentName, title, score, maxScore, percentage, gradedAt];
}

/// A single student's score, as submitted in a grades POST.
class GradeEntryInput extends Equatable {
  final int studentId;
  final double score;

  const GradeEntryInput({required this.studentId, required this.score});

  @override
  List<Object?> get props => [studentId, score];
}
