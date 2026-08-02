import 'package:equatable/equatable.dart';
import '../../domain/entities/trip.dart';

abstract class TeacherTripsState extends Equatable {
  const TeacherTripsState();
  @override
  List<Object?> get props => [];
}

class TeacherTripsLoading extends TeacherTripsState {
  const TeacherTripsLoading();
}

class TeacherTripsLoaded extends TeacherTripsState {
  final GeoPoint school;
  final List<Trip> trips;
  const TeacherTripsLoaded({required this.school, required this.trips});
  @override
  List<Object?> get props => [school, trips];
}

class TeacherTripsError extends TeacherTripsState {
  final String message;
  const TeacherTripsError(this.message);
  @override
  List<Object?> get props => [message];
}
