import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/exam_entities.dart';
import '../models/exam_models.dart';

abstract class ExamsRemoteDataSource {
  Future<List<MyExamModel>> getMyExams();
  Future<List<ExamModel>> getExams();
  Future<ExamModel> getExamDetail(int examId);
  Future<ExamAttemptModel> startExam(int examId);
  Future<ExamAttemptModel> submitAttempt(
      int attemptId, List<AttemptAnswer> answers);
  Future<ExamAttemptModel> getAttemptResult(int attemptId);
}

class ExamsRemoteDataSourceImpl implements ExamsRemoteDataSource {
  final Dio dio;
  ExamsRemoteDataSourceImpl(this.dio);

  dynamic _extractData(dynamic response) {
    if (response is Map<String, dynamic> && response['data'] != null) {
      return response['data'];
    }
    return response;
  }

  void _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      throw const NetworkException();
    }
    final statusCode = e.response?.statusCode;
    if (statusCode == 401) throw const UnauthorizedException();
    if (statusCode == 404) throw const NotFoundException();
    throw ServerException(
      e.response?.data?['message'] as String? ?? 'حدث خطأ في الخادم',
      statusCode: statusCode,
    );
  }

  @override
  Future<List<MyExamModel>> getMyExams() async {
    try {
      final response = await dio.get(ApiEndpoints.studentMyExams);
      final data = _extractData(response.data);
      final list = data is List ? data : (data['exams'] as List<dynamic>? ?? []);
      return list
          .map((e) => MyExamModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      if (e is NetworkException ||
          e is UnauthorizedException ||
          e is NotFoundException ||
          e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ExamModel>> getExams() async {
    try {
      final response = await dio.get(ApiEndpoints.studentExams);
      final data = _extractData(response.data);
      final list = data is List ? data : (data['exams'] as List<dynamic>? ?? []);
      return list
          .map((e) => ExamModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      if (e is NetworkException ||
          e is UnauthorizedException ||
          e is NotFoundException ||
          e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ExamModel> getExamDetail(int examId) async {
    try {
      final response = await dio.get(ApiEndpoints.studentExamDetail(examId));
      final data = _extractData(response.data);
      return ExamModel.fromJson(data is Map<String, dynamic> ? data : {});
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      if (e is NetworkException ||
          e is UnauthorizedException ||
          e is NotFoundException ||
          e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ExamAttemptModel> startExam(int examId) async {
    try {
      final response = await dio.post(ApiEndpoints.studentStartExam(examId));
      final data = _extractData(response.data);
      return ExamAttemptModel.fromJson(
          data is Map<String, dynamic> ? data : {});
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      if (e is NetworkException ||
          e is UnauthorizedException ||
          e is NotFoundException ||
          e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ExamAttemptModel> submitAttempt(
      int attemptId, List<AttemptAnswer> answers) async {
    try {
      final answersPayload = answers
          .map((a) => AttemptAnswerModel(
                questionId: a.questionId,
                selectedOptionId: a.selectedOptionId,
              ).toJson())
          .toList();
      final response = await dio.post(
        ApiEndpoints.studentSubmitAttempt(attemptId),
        data: {'answers': answersPayload},
      );
      final data = _extractData(response.data);
      return ExamAttemptModel.fromJson(
          data is Map<String, dynamic> ? data : {});
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      if (e is NetworkException ||
          e is UnauthorizedException ||
          e is NotFoundException ||
          e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ExamAttemptModel> getAttemptResult(int attemptId) async {
    try {
      final response =
          await dio.get(ApiEndpoints.studentAttemptResult(attemptId));
      final data = _extractData(response.data);
      return ExamAttemptModel.fromJson(
          data is Map<String, dynamic> ? data : {});
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      if (e is NetworkException ||
          e is UnauthorizedException ||
          e is NotFoundException ||
          e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
