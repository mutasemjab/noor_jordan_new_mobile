import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/student_trip.dart';
import '../../domain/repositories/student_trip_repository.dart';
import '../datasources/student_trip_remote_datasource.dart';

class StudentTripRepositoryImpl implements StudentTripRepository {
  final StudentTripRemoteDataSource _remote;
  final NetworkInfo _network;

  StudentTripRepositoryImpl(this._remote, this._network);

  @override
  Future<Either<Failure, StudentTrip?>> getMyTrip() async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await _remote.getMyTrip());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
