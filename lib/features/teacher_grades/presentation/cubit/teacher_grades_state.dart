import 'package:equatable/equatable.dart';
import '../../../classes/domain/entities/school_class.dart';
import '../../../teacher_common/domain/entities/teacher_subject.dart';
import '../../domain/entities/teacher_grades.dart';

abstract class TeacherGradesState extends Equatable {
  const TeacherGradesState();
  @override
  List<Object?> get props => [];
}

/// No subject chosen yet — the caller should show the subject picker.
class TeacherGradesInitial extends TeacherGradesState {
  const TeacherGradesInitial();
}

class TeacherGradesLoading extends TeacherGradesState {
  const TeacherGradesLoading();
}

class TeacherGradesLoaded extends TeacherGradesState {
  final TeacherSubject subject;
  final List<ClassStudent> roster;
  final List<GradeRecord> records;

  const TeacherGradesLoaded({
    required this.subject,
    required this.roster,
    required this.records,
  });

  @override
  List<Object?> get props => [subject, roster, records];
}

class TeacherGradesError extends TeacherGradesState {
  final String message;
  const TeacherGradesError(this.message);
  @override
  List<Object?> get props => [message];
}
