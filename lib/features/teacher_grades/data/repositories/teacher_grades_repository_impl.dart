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
  Future<Either<Failure, List<GradeRecord>>> getGrades({
    required int classId,
    required int subjectId,
    String? title,
  }) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await _remote.getGrades(classId: classId, subjectId: subjectId, title: title));
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
  Future<Either<Failure, void>> submitGrades({
    required int classId,
    required int subjectId,
    required String title,
    required double maxScore,
    required DateTime gradedAt,
    required List<GradeEntryInput> grades,
  }) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      final gradedAtStr =
          '${gradedAt.year.toString().padLeft(4, '0')}-${gradedAt.month.toString().padLeft(2, '0')}-${gradedAt.day.toString().padLeft(2, '0')}';
      await _remote.submitGrades({
        'class_id': classId,
        'subject_id': subjectId,
        'title': title,
        'max_score': maxScore,
        'graded_at': gradedAtStr,
        'grades': grades.map((g) => {'student_id': g.studentId, 'score': g.score}).toList(),
      });
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
