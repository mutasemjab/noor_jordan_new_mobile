import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/exam_schedule.dart';
import '../../domain/repositories/exam_schedules_repository.dart';
import '../datasources/exam_schedules_remote_datasource.dart';

class ExamSchedulesRepositoryImpl implements ExamSchedulesRepository {
  final ExamSchedulesRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  ExamSchedulesRepositoryImpl(this._remoteDataSource, this._networkInfo);

  @override
  Future<Either<Failure, List<ExamSchedule>>> getExamSchedules() async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final result = await _remoteDataSource.getExamSchedules();
      return Right(result);
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
