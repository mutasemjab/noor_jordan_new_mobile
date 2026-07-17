import 'package:equatable/equatable.dart';
import '../../domain/entities/teacher_schedule.dart';

abstract class TeacherScheduleState extends Equatable {
  const TeacherScheduleState();
  @override
  List<Object?> get props => [];
}

class TeacherScheduleInitial extends TeacherScheduleState {}
class TeacherScheduleLoading extends TeacherScheduleState {}

class TeacherScheduleLoaded extends TeacherScheduleState {
  final List<TeacherDaySchedule> schedule;
  final int selectedDayIndex;
  const TeacherScheduleLoaded(this.schedule, {this.selectedDayIndex = 0});
  @override
  List<Object?> get props => [schedule, selectedDayIndex];
}

class TeacherScheduleError extends TeacherScheduleState {
  final String message;
  const TeacherScheduleError(this.message);
  @override
  List<Object?> get props => [message];
}
