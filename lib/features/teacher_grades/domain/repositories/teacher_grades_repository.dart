import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/teacher_grades.dart';

abstract class TeacherGradesRepository {
  Future<Either<Failure, List<GradeRecord>>> getGrades({
    required int classId,
    required int subjectId,
    String? title,
  });

  Future<Either<Failure, void>> submitGrades({
    required int classId,
    required int subjectId,
    required String title,
    required double maxScore,
    required DateTime gradedAt,
    required List<GradeEntryInput> grades,
  });
}
