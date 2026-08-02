import 'package:equatable/equatable.dart';
import '../../domain/entities/teacher_exam.dart';

abstract class TeacherExamDetailState extends Equatable {
  const TeacherExamDetailState();
  @override
  List<Object?> get props => [];
}

class TeacherExamDetailLoading extends TeacherExamDetailState {
  const TeacherExamDetailLoading();
}

class TeacherExamDetailLoaded extends TeacherExamDetailState {
  final TeacherExam exam;
  const TeacherExamDetailLoaded(this.exam);
  @override
  List<Object?> get props => [exam];
}

class TeacherExamDetailError extends TeacherExamDetailState {
  final String message;
  const TeacherExamDetailError(this.message);
  @override
  List<Object?> get props => [message];
}
