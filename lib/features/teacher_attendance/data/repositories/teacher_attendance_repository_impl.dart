import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/teacher_attendance.dart';
import '../../domain/repositories/teacher_attendance_repository.dart';
import '../datasources/teacher_attendance_remote_datasource.dart';

class TeacherAttendanceRepositoryImpl implements TeacherAttendanceRepository {
  final TeacherAttendanceRemoteDataSource _remote;
  final NetworkInfo _network;

  TeacherAttendanceRepositoryImpl(this._remote, this._network);

  @override
  Future<Either<Failure, List<TeacherAttendanceClass>>> getClasses() async {
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
  Future<Either<Failure, List<AttendanceEntry>>> getStudents(int classId) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await _remote.getStudents(classId));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> submitAttendance({
    required int classId,
    required String date,
    required List<Map<String, dynamic>> entries,
  }) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      await _remote.submitAttendance(classId: classId, date: date, entries: entries);
      return const Right(null);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
