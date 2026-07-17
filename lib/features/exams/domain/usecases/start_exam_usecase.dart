import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/exam_entities.dart';
import '../repositories/exams_repository.dart';

class StartExamUseCase {
  final ExamsRepository repository;
  StartExamUseCase(this.repository);

  Future<Either<Failure, ExamAttempt>> call(int examId) {
    return repository.startExam(examId);
  }
}
