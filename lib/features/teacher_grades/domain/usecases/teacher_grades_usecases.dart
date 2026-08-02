import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/teacher_grades.dart';
import '../repositories/teacher_grades_repository.dart';

class GetTeacherGradesUseCase {
  final TeacherGradesRepository _repository;
  GetTeacherGradesUseCase(this._repository);

  Future<Either<Failure, List<GradeRecord>>> call({
    required int classId,
    required int subjectId,
    String? title,
  }) =>
      _repository.getGrades(classId: classId, subjectId: subjectId, title: title);
}

class SubmitGradesUseCase {
  final TeacherGradesRepository _repository;
  SubmitGradesUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required int classId,
    required int subjectId,
    required String title,
    required double maxScore,
    required DateTime gradedAt,
    required List<GradeEntryInput> grades,
  }) =>
      _repository.submitGrades(
        classId: classId,
        subjectId: subjectId,
        title: title,
        maxScore: maxScore,
        gradedAt: gradedAt,
        grades: grades,
      );
}
