import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/teacher_grades.dart';

abstract class TeacherGradesRepository {
  Future<Either<Failure, List<GradeClass>>> getClasses();
  Future<Either<Failure, List<GradeExamType>>> getExamTypes(int classId);
  Future<Either<Failure, List<StudentGradeEntry>>> getStudentGrades(int classId, int examTypeId);
  Future<Either<Failure, void>> submitGrades({
    required int classId,
    required int examTypeId,
    required List<Map<String, dynamic>> grades,
  });
}
