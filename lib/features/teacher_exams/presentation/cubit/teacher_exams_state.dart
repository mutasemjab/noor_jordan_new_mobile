import 'package:equatable/equatable.dart';
import '../../domain/entities/teacher_exam.dart';

abstract class TeacherExamsState extends Equatable {
  const TeacherExamsState();
  @override
  List<Object?> get props => [];
}

class TeacherExamsLoading extends TeacherExamsState {
  const TeacherExamsLoading();
}

class TeacherExamsLoaded extends TeacherExamsState {
  final List<TeacherExam> exams;
  const TeacherExamsLoaded(this.exams);
  @override
  List<Object?> get props => [exams];
}

class TeacherExamsError extends TeacherExamsState {
  final String message;
  const TeacherExamsError(this.message);
  @override
  List<Object?> get props => [message];
}

/// Result of a create action — carries either the created exam (so the
/// caller can navigate to its detail page) or an error message.
class ExamActionResult {
  final TeacherExam? exam;
  final String? error;
  const ExamActionResult({this.exam, this.error});
}
