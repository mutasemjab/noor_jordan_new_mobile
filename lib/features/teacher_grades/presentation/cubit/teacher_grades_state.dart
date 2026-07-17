import 'package:equatable/equatable.dart';
import '../../domain/entities/teacher_grades.dart';

abstract class TeacherGradesState extends Equatable {
  const TeacherGradesState();
  @override
  List<Object?> get props => [];
}

class TeacherGradesInitial extends TeacherGradesState {}
class TeacherGradesLoading extends TeacherGradesState {}

class TeacherGradesClassesLoaded extends TeacherGradesState {
  final List<GradeClass> classes;
  const TeacherGradesClassesLoaded(this.classes);
  @override
  List<Object?> get props => [classes];
}

class TeacherGradesExamTypesLoaded extends TeacherGradesState {
  final List<GradeClass> classes;
  final GradeClass selectedClass;
  final List<GradeExamType> examTypes;

  const TeacherGradesExamTypesLoaded({
    required this.classes,
    required this.selectedClass,
    required this.examTypes,
  });

  @override
  List<Object?> get props => [classes, selectedClass, examTypes];
}

class TeacherGradesStudentsLoaded extends TeacherGradesState {
  final List<GradeClass> classes;
  final GradeClass selectedClass;
  final List<GradeExamType> examTypes;
  final GradeExamType selectedExamType;
  final List<StudentGradeEntry> entries;

  const TeacherGradesStudentsLoaded({
    required this.classes,
    required this.selectedClass,
    required this.examTypes,
    required this.selectedExamType,
    required this.entries,
  });

  TeacherGradesStudentsLoaded copyWith({List<StudentGradeEntry>? entries}) {
    return TeacherGradesStudentsLoaded(
      classes: classes,
      selectedClass: selectedClass,
      examTypes: examTypes,
      selectedExamType: selectedExamType,
      entries: entries ?? this.entries,
    );
  }

  @override
  List<Object?> get props => [classes, selectedClass, examTypes, selectedExamType, entries];
}

class TeacherGradesSubmitting extends TeacherGradesState {}
class TeacherGradesSubmitted extends TeacherGradesState {}

class TeacherGradesError extends TeacherGradesState {
  final String message;
  const TeacherGradesError(this.message);
  @override
  List<Object?> get props => [message];
}
