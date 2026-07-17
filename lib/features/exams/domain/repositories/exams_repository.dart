import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/exam_entities.dart';

abstract class ExamsRepository {
  Future<Either<Failure, List<MyExam>>> getMyExams();
  Future<Either<Failure, List<Exam>>> getExams();
  Future<Either<Failure, Exam>> getExamDetail(int examId);
  Future<Either<Failure, ExamAttempt>> startExam(int examId);
  Future<Either<Failure, ExamAttempt>> submitAttempt(
      int attemptId, List<AttemptAnswer> answers);
  Future<Either<Failure, ExamAttempt>> getAttemptResult(int attemptId);
}
