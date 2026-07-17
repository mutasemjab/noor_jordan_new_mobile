import 'package:equatable/equatable.dart';
import '../../domain/entities/teacher_attendance.dart';

abstract class TeacherAttendanceState extends Equatable {
  const TeacherAttendanceState();
  @override
  List<Object?> get props => [];
}

class TeacherAttendanceInitial extends TeacherAttendanceState {}
class TeacherAttendanceLoading extends TeacherAttendanceState {}

class TeacherAttendanceClassesLoaded extends TeacherAttendanceState {
  final List<TeacherAttendanceClass> classes;
  final TeacherAttendanceClass? selectedClass;

  const TeacherAttendanceClassesLoaded(this.classes, {this.selectedClass});

  @override
  List<Object?> get props => [classes, selectedClass];
}

class TeacherAttendanceStudentsLoaded extends TeacherAttendanceState {
  final List<TeacherAttendanceClass> classes;
  final TeacherAttendanceClass selectedClass;
  final List<AttendanceEntry> entries;
  final String date;

  const TeacherAttendanceStudentsLoaded({
    required this.classes,
    required this.selectedClass,
    required this.entries,
    required this.date,
  });

  TeacherAttendanceStudentsLoaded copyWith({
    List<AttendanceEntry>? entries,
    TeacherAttendanceClass? selectedClass,
    String? date,
  }) {
    return TeacherAttendanceStudentsLoaded(
      classes: classes,
      selectedClass: selectedClass ?? this.selectedClass,
      entries: entries ?? this.entries,
      date: date ?? this.date,
    );
  }

  @override
  List<Object?> get props => [classes, selectedClass, entries, date];
}

class TeacherAttendanceSubmitting extends TeacherAttendanceState {}

class TeacherAttendanceSubmitted extends TeacherAttendanceState {}

class TeacherAttendanceError extends TeacherAttendanceState {
  final String message;
  const TeacherAttendanceError(this.message);
  @override
  List<Object?> get props => [message];
}
