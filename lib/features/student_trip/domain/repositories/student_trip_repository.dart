import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/student_trip.dart';

abstract class StudentTripRepository {
  Future<Either<Failure, StudentTrip?>> getMyTrip();
}
