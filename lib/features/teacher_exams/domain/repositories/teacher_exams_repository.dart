import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/teacher_exam.dart';

abstract class TeacherExamsRepository {
  Future<Either<Failure, List<TeacherExam>>> getExams({int? classId, int? subjectId});

  Future<Either<Failure, TeacherExam>> getExamDetail(int id);

  Future<Either<Failure, TeacherExam>> createExam({
    required int classId,
    required int subjectId,
    required String titleAr,
    String? descriptionAr,
    required String examType,
    required int durationMinutes,
    required int totalMarks,
    int? passMarks,
    String? difficultyLevel,
    required bool isPublished,
    required bool showResultImmediately,
  });

  Future<Either<Failure, TeacherExam>> updateExam({
    required int id,
    required String titleAr,
    String? descriptionAr,
    required String examType,
    required int durationMinutes,
    required int totalMarks,
    int? passMarks,
    String? difficultyLevel,
    required bool isPublished,
    required bool showResultImmediately,
  });

  Future<Either<Failure, void>> deleteExam(int id);

  Future<Either<Failure, TeacherExamQuestion>> createQuestion({
    required int examId,
    required TeacherExamQuestion question,
  });

  Future<Either<Failure, TeacherExamQuestion>> updateQuestion({
    required int examId,
    required int questionId,
    required TeacherExamQuestion question,
  });

  Future<Either<Failure, void>> deleteQuestion({required int examId, required int questionId});
}
