import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/trip.dart';

abstract class TeacherTripsRepository {
  Future<Either<Failure, MyTripsData>> getMyTrips();

  Future<Either<Failure, Trip>> startTrip(int tripId);

  Future<Either<Failure, LocationUpdateResult>> sendLocation({
    required int tripId,
    required double lat,
    required double lng,
  });

  Future<Either<Failure, void>> markStudentArrived({required int tripId, required int studentId});

  Future<Either<Failure, void>> completeTrip(int tripId);
}
