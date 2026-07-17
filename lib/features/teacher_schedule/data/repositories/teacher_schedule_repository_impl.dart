import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/teacher_schedule.dart';
import '../../domain/repositories/teacher_schedule_repository.dart';
import '../datasources/teacher_schedule_remote_datasource.dart';

class TeacherScheduleRepositoryImpl implements TeacherScheduleRepository {
  final TeacherScheduleRemoteDataSource _remote;
  final NetworkInfo _network;

  TeacherScheduleRepositoryImpl(this._remote, this._network);

  @override
  Future<Either<Failure, List<TeacherDaySchedule>>> getSchedule() async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await _remote.getSchedule());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
