import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/teacher_grades_repository.dart';

class SubmitGradesUseCase {
  final TeacherGradesRepository _repository;
  SubmitGradesUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required int classId,
    required int examTypeId,
    required List<Map<String, dynamic>> grades,
  }) =>
      _repository.submitGrades(classId: classId, examTypeId: examTypeId, grades: grades);
}
