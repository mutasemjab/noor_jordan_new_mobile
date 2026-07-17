import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/teacher_grades.dart';
import '../repositories/teacher_grades_repository.dart';

class GetGradeClassesUseCase {
  final TeacherGradesRepository _repository;
  GetGradeClassesUseCase(this._repository);

  Future<Either<Failure, List<GradeClass>>> call() => _repository.getClasses();
}
