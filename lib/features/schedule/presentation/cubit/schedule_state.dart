import 'package:equatable/equatable.dart';
import '../../domain/entities/schedule.dart';

abstract class ScheduleState extends Equatable {
  const ScheduleState();

  @override
  List<Object?> get props => [];
}

class ScheduleInitial extends ScheduleState {
  const ScheduleInitial();
}

class ScheduleLoading extends ScheduleState {
  const ScheduleLoading();
}

class ScheduleLoaded extends ScheduleState {
  final List<DaySchedule> schedule;
  final int selectedDayIndex;

  const ScheduleLoaded(this.schedule, {this.selectedDayIndex = 0});

  ScheduleLoaded copyWith({
    List<DaySchedule>? schedule,
    int? selectedDayIndex,
  }) {
    return ScheduleLoaded(
      schedule ?? this.schedule,
      selectedDayIndex: selectedDayIndex ?? this.selectedDayIndex,
    );
  }

  @override
  List<Object?> get props => [schedule, selectedDayIndex];
}

class ScheduleError extends ScheduleState {
  final String message;

  const ScheduleError(this.message);

  @override
  List<Object?> get props => [message];
}
