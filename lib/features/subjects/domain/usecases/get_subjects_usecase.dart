import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/subject.dart';
import '../repositories/subjects_repository.dart';

class GetSubjectsUseCase {
  final SubjectsRepository repository;
  GetSubjectsUseCase(this.repository);

  Future<Either<Failure, List<Subject>>> call() {
    return repository.getSubjects();
  }
}
