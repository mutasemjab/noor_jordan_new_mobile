import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/school_class.dart';
import '../../domain/repositories/classes_repository.dart';
import '../datasources/classes_remote_datasource.dart';

class ClassesRepositoryImpl implements ClassesRepository {
  final ClassesRemoteDataSource _remote;
  final NetworkInfo _network;

  ClassesRepositoryImpl(this._remote, this._network);

  @override
  Future<Either<Failure, List<SchoolClass>>> getClasses() async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await _remote.getClasses());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<ClassStudent>>> getClassStudents(int classId) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await _remote.getClassStudents(classId));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
