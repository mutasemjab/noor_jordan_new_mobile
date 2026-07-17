import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/exam_entities.dart';
import '../repositories/exams_repository.dart';

class SubmitExamUseCase {
  final ExamsRepository repository;
  SubmitExamUseCase(this.repository);

  Future<Either<Failure, ExamAttempt>> call(
      int attemptId, List<AttemptAnswer> answers) {
    return repository.submitAttempt(attemptId, answers);
  }
}
