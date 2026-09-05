import 'package:equatable/equatable.dart';
import '../../domain/entities/educational_note.dart';

abstract class NoteDatesState extends Equatable {
  const NoteDatesState();
  @override
  List<Object?> get props => [];
}

class NoteDatesInitial extends NoteDatesState {}

class NoteDatesLoading extends NoteDatesState {}

class NoteDatesLoaded extends NoteDatesState {
  final List<NoteDateSummary> dates;
  const NoteDatesLoaded(this.dates);
  @override
  List<Object?> get props => [dates];
}

class NoteDatesError extends NoteDatesState {
  final String message;
  const NoteDatesError(this.message);
  @override
  List<Object?> get props => [message];
}
