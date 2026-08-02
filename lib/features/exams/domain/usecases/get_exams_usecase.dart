import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/exam_entities.dart';
import '../repositories/exams_repository.dart';

class GetExamsUseCase {
  final ExamsRepository repository;
  GetExamsUseCase(this.repository);

  Future<Either<Failure, List<Exam>>> call() {
    return repository.getExams();
  }
}
