import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/teacher_grades.dart';
import '../../domain/repositories/teacher_grades_repository.dart';
import '../datasources/teacher_grades_remote_datasource.dart';

class TeacherGradesRepositoryImpl implements TeacherGradesRepository {
  final TeacherGradesRemoteDataSource _remote;
  final NetworkInfo _network;

  TeacherGradesRepositoryImpl(this._remote, this._network);

  @override
  Future<Either<Failure, List<GradeClass>>> getClasses() async {
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
  Future<Either<Failure, List<GradeExamType>>> getExamTypes(int classId) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await _remote.getExamTypes(classId));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<StudentGradeEntry>>> getStudentGrades(int classId, int examTypeId) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await _remote.getStudentGrades(classId, examTypeId));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> submitGrades({
    required int classId,
    required int examTypeId,
    required List<Map<String, dynamic>> grades,
  }) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      await _remote.submitGrades(classId: classId, examTypeId: examTypeId, grades: grades);
      return const Right(null);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
