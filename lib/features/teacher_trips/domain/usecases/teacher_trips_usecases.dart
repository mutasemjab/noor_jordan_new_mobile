import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/trip.dart';
import '../repositories/teacher_trips_repository.dart';

class GetMyTripsUseCase {
  final TeacherTripsRepository _repository;
  GetMyTripsUseCase(this._repository);
  Future<Either<Failure, MyTripsData>> call() => _repository.getMyTrips();
}

class StartTripUseCase {
  final TeacherTripsRepository _repository;
  StartTripUseCase(this._repository);
  Future<Either<Failure, Trip>> call(int tripId) => _repository.startTrip(tripId);
}

class SendTripLocationUseCase {
  final TeacherTripsRepository _repository;
  SendTripLocationUseCase(this._repository);
  Future<Either<Failure, LocationUpdateResult>> call({required int tripId, required double lat, required double lng}) =>
      _repository.sendLocation(tripId: tripId, lat: lat, lng: lng);
}

class MarkTripStudentArrivedUseCase {
  final TeacherTripsRepository _repository;
  MarkTripStudentArrivedUseCase(this._repository);
  Future<Either<Failure, void>> call({required int tripId, required int studentId}) =>
      _repository.markStudentArrived(tripId: tripId, studentId: studentId);
}

class CompleteTripUseCase {
  final TeacherTripsRepository _repository;
  CompleteTripUseCase(this._repository);
  Future<Either<Failure, void>> call(int tripId) => _repository.completeTrip(tripId);
}
