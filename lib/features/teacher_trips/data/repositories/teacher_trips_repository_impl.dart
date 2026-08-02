import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/trip.dart';
import '../../domain/repositories/teacher_trips_repository.dart';
import '../datasources/teacher_trips_remote_datasource.dart';

class TeacherTripsRepositoryImpl implements TeacherTripsRepository {
  final TeacherTripsRemoteDataSource _remote;
  final NetworkInfo _network;

  TeacherTripsRepositoryImpl(this._remote, this._network);

  @override
  Future<Either<Failure, MyTripsData>> getMyTrips() async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      final result = await _remote.getMyTrips();
      return Right(MyTripsData(school: result.school, trips: result.trips));
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

  @override
  Future<Either<Failure, Trip>> startTrip(int tripId) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await _remote.startTrip(tripId));
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

  @override
  Future<Either<Failure, LocationUpdateResult>> sendLocation({
    required int tripId,
    required double lat,
    required double lng,
  }) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await _remote.sendLocation(tripId: tripId, lat: lat, lng: lng));
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

  @override
  Future<Either<Failure, void>> markStudentArrived({required int tripId, required int studentId}) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      await _remote.markStudentArrived(tripId: tripId, studentId: studentId);
      return const Right(null);
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

  @override
  Future<Either<Failure, void>> completeTrip(int tripId) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      await _remote.completeTrip(tripId);
      return const Right(null);
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
