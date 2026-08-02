import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/exam_entities.dart';
import '../repositories/exams_repository.dart';

class GetExamDetailUseCase {
  final ExamsRepository repository;
  GetExamDetailUseCase(this.repository);

  Future<Either<Failure, Exam>> call(int examId) {
    return repository.getExamDetail(examId);
  }
}
