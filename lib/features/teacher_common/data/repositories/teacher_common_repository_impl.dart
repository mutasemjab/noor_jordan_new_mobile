import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/teacher_subject.dart';
import '../../domain/repositories/teacher_common_repository.dart';
import '../datasources/teacher_common_remote_datasource.dart';

class TeacherCommonRepositoryImpl implements TeacherCommonRepository {
  final TeacherCommonRemoteDataSource _remote;
  final NetworkInfo _network;

  TeacherCommonRepositoryImpl(this._remote, this._network);

  @override
  Future<Either<Failure, List<TeacherSubject>>> getClassSubjects(int classId) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await _remote.getClassSubjects(classId));
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
