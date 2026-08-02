import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/student_trip.dart';
import '../repositories/student_trip_repository.dart';

class GetMyTripUseCase {
  final StudentTripRepository _repository;
  GetMyTripUseCase(this._repository);
  Future<Either<Failure, StudentTrip?>> call() => _repository.getMyTrip();
}
