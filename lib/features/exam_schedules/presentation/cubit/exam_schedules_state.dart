import 'package:equatable/equatable.dart';
import '../../domain/entities/exam_schedule.dart';

abstract class ExamSchedulesState extends Equatable {
  const ExamSchedulesState();

  @override
  List<Object?> get props => [];
}

class ExamSchedulesInitial extends ExamSchedulesState {
  const ExamSchedulesInitial();
}

class ExamSchedulesLoading extends ExamSchedulesState {
  const ExamSchedulesLoading();
}

class ExamSchedulesLoaded extends ExamSchedulesState {
  final List<ExamSchedule> items;

  const ExamSchedulesLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

class ExamSchedulesError extends ExamSchedulesState {
  final String message;

  const ExamSchedulesError(this.message);

  @override
  List<Object?> get props => [message];
}
