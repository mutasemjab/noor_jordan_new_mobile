import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/exam_entities.dart';
import '../repositories/exams_repository.dart';

class GetMyExamsUseCase {
  final ExamsRepository repository;
  GetMyExamsUseCase(this.repository);

  Future<Either<Failure, List<MyExam>>> call() {
    return repository.getMyExams();
  }
}
