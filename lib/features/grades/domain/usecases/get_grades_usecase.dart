import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/grade.dart';
import '../repositories/grades_repository.dart';

class GetGradesUseCase {
  final GradesRepository _repository;

  GetGradesUseCase(this._repository);

  Future<Either<Failure, List<SubjectGrades>>> call() {
    return _repository.getGrades();
  }
}
