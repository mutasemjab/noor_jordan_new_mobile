import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/teacher_exam.dart';
import '../repositories/teacher_exams_repository.dart';

class GetTeacherExamsUseCase {
  final TeacherExamsRepository _repository;
  GetTeacherExamsUseCase(this._repository);
  Future<Either<Failure, List<TeacherExam>>> call({int? classId, int? subjectId}) =>
      _repository.getExams(classId: classId, subjectId: subjectId);
}

class GetTeacherExamDetailUseCase {
  final TeacherExamsRepository _repository;
  GetTeacherExamDetailUseCase(this._repository);
  Future<Either<Failure, TeacherExam>> call(int id) => _repository.getExamDetail(id);
}

class CreateExamUseCase {
  final TeacherExamsRepository _repository;
  CreateExamUseCase(this._repository);
  Future<Either<Failure, TeacherExam>> call({
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
  }) =>
      _repository.createExam(
        classId: classId,
        subjectId: subjectId,
        titleAr: titleAr,
        descriptionAr: descriptionAr,
        examType: examType,
        durationMinutes: durationMinutes,
        totalMarks: totalMarks,
        passMarks: passMarks,
        difficultyLevel: difficultyLevel,
        isPublished: isPublished,
        showResultImmediately: showResultImmediately,
      );
}

class UpdateExamUseCase {
  final TeacherExamsRepository _repository;
  UpdateExamUseCase(this._repository);
  Future<Either<Failure, TeacherExam>> call({
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
  }) =>
      _repository.updateExam(
        id: id,
        titleAr: titleAr,
        descriptionAr: descriptionAr,
        examType: examType,
        durationMinutes: durationMinutes,
        totalMarks: totalMarks,
        passMarks: passMarks,
        difficultyLevel: difficultyLevel,
        isPublished: isPublished,
        showResultImmediately: showResultImmediately,
      );
}

class DeleteExamUseCase {
  final TeacherExamsRepository _repository;
  DeleteExamUseCase(this._repository);
  Future<Either<Failure, void>> call(int id) => _repository.deleteExam(id);
}

class CreateExamQuestionUseCase {
  final TeacherExamsRepository _repository;
  CreateExamQuestionUseCase(this._repository);
  Future<Either<Failure, TeacherExamQuestion>> call({required int examId, required TeacherExamQuestion question}) =>
      _repository.createQuestion(examId: examId, question: question);
}

class UpdateExamQuestionUseCase {
  final TeacherExamsRepository _repository;
  UpdateExamQuestionUseCase(this._repository);
  Future<Either<Failure, TeacherExamQuestion>> call({
    required int examId,
    required int questionId,
    required TeacherExamQuestion question,
  }) =>
      _repository.updateQuestion(examId: examId, questionId: questionId, question: question);
}

class DeleteExamQuestionUseCase {
  final TeacherExamsRepository _repository;
  DeleteExamQuestionUseCase(this._repository);
  Future<Either<Failure, void>> call({required int examId, required int questionId}) =>
      _repository.deleteQuestion(examId: examId, questionId: questionId);
}
