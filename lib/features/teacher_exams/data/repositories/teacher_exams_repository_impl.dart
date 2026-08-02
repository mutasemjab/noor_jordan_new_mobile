import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/teacher_exam.dart';
import '../../domain/repositories/teacher_exams_repository.dart';
import '../datasources/teacher_exams_remote_datasource.dart';

class TeacherExamsRepositoryImpl implements TeacherExamsRepository {
  final TeacherExamsRemoteDataSource _remote;
  final NetworkInfo _network;

  TeacherExamsRepositoryImpl(this._remote, this._network);

  Map<String, dynamic> _examBody({
    int? classId,
    int? subjectId,
    required String titleAr,
    String? descriptionAr,
    required String examType,
    required int durationMinutes,
    required int totalMarks,
    int? passMarks,
    String? difficultyLevel,
    required bool isPublished,
    required bool showResultImmediately,
  }) {
    return {
      if (classId != null) 'class_id': classId,
      if (subjectId != null) 'subject_id': subjectId,
      'title_ar': titleAr,
      if (descriptionAr != null && descriptionAr.isNotEmpty) 'description_ar': descriptionAr,
      'exam_type': examType,
      'duration_minutes': durationMinutes,
      'total_marks': totalMarks,
      if (passMarks != null) 'pass_marks': passMarks,
      if (difficultyLevel != null) 'difficulty_level': difficultyLevel,
      'is_published': isPublished,
      'show_result_immediately': showResultImmediately,
    };
  }

  Map<String, dynamic> _questionBody(TeacherExamQuestion question) {
    return {
      'question_ar': question.questionAr,
      'question_type': question.questionType,
      'marks': question.marks,
      if (question.difficulty != null) 'difficulty': question.difficulty,
      if (question.explanationAr != null && question.explanationAr!.isNotEmpty) 'explanation_ar': question.explanationAr,
      'options': question.options
          .map((o) => {
                'option_text_ar': o.textAr,
                'is_correct': o.isCorrect,
              })
          .toList(),
    };
  }

  @override
  Future<Either<Failure, List<TeacherExam>>> getExams({int? classId, int? subjectId}) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await _remote.getExams(classId: classId, subjectId: subjectId));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, TeacherExam>> getExamDetail(int id) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await _remote.getExamDetail(id));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
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
  }) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      final body = _examBody(
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
      return Right(await _remote.createExam(body));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
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
  }) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      final body = _examBody(
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
      return Right(await _remote.updateExam(id, body));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteExam(int id) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      await _remote.deleteExam(id);
      return const Right(null);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, TeacherExamQuestion>> createQuestion({
    required int examId,
    required TeacherExamQuestion question,
  }) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      final body = _questionBody(question);
      return Right(await _remote.createQuestion(examId, body));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, TeacherExamQuestion>> updateQuestion({
    required int examId,
    required int questionId,
    required TeacherExamQuestion question,
  }) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      final body = _questionBody(question);
      return Right(await _remote.updateQuestion(examId, questionId, body));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteQuestion({required int examId, required int questionId}) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      await _remote.deleteQuestion(examId, questionId);
      return const Right(null);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
