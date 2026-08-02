import 'package:equatable/equatable.dart';
import '../../domain/entities/trip.dart';

abstract class TripExecutionState extends Equatable {
  const TripExecutionState();
  @override
  List<Object?> get props => [];
}

class TripExecutionActive extends TripExecutionState {
  final Trip trip;
  final NextStop? nextStop;
  final String? toastMessage;
  final Set<int> arrivedStudentIds;

  const TripExecutionActive({
    required this.trip,
    this.nextStop,
    this.toastMessage,
    this.arrivedStudentIds = const {},
  });

  TripExecutionActive copyWith({NextStop? nextStop, String? toastMessage, Set<int>? arrivedStudentIds}) {
    return TripExecutionActive(
      trip: trip,
      nextStop: nextStop,
      toastMessage: toastMessage,
      arrivedStudentIds: arrivedStudentIds ?? this.arrivedStudentIds,
    );
  }

  @override
  List<Object?> get props => [trip, nextStop, toastMessage, arrivedStudentIds];
}

class TripExecutionCompleted extends TripExecutionState {
  const TripExecutionCompleted();
}

class TripExecutionError extends TripExecutionState {
  final String message;
  const TripExecutionError(this.message);
  @override
  List<Object?> get props => [message];
}
