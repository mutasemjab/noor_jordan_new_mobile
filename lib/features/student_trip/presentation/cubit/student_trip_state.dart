import 'package:equatable/equatable.dart';
import '../../domain/entities/student_trip.dart';

abstract class StudentTripState extends Equatable {
  const StudentTripState();
  @override
  List<Object?> get props => [];
}

class StudentTripLoading extends StudentTripState {
  const StudentTripLoading();
}

class StudentTripLoaded extends StudentTripState {
  final StudentTrip? trip;
  const StudentTripLoaded(this.trip);
  @override
  List<Object?> get props => [trip];
}

class StudentTripError extends StudentTripState {
  final String message;
  const StudentTripError(this.message);
  @override
  List<Object?> get props => [message];
}
