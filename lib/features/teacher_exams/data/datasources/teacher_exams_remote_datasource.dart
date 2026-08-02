import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/teacher_exam_model.dart';

abstract class TeacherExamsRemoteDataSource {
  Future<List<TeacherExamModel>> getExams({int? classId, int? subjectId});
  Future<TeacherExamModel> getExamDetail(int id);

  Future<TeacherExamModel> createExam(Map<String, dynamic> body);
  Future<TeacherExamModel> updateExam(int id, Map<String, dynamic> body);
  Future<void> deleteExam(int id);

  Future<TeacherExamQuestionModel> createQuestion(int examId, Map<String, dynamic> body);
  Future<TeacherExamQuestionModel> updateQuestion(int examId, int questionId, Map<String, dynamic> body);
  Future<void> deleteQuestion(int examId, int questionId);
}

class TeacherExamsRemoteDataSourceImpl implements TeacherExamsRemoteDataSource {
  final Dio _dio;
  TeacherExamsRemoteDataSourceImpl(this._dio);

  @override
  Future<List<TeacherExamModel>> getExams({int? classId, int? subjectId}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.teacherExams,
        queryParameters: {
          if (classId != null) 'class_id': classId,
          if (subjectId != null) 'subject_id': subjectId,
        },
      );
      final data = response.data;
      final list = data is Map<String, dynamic> ? data['data'] as List<dynamic>? ?? [] : <dynamic>[];
      return list.whereType<Map<String, dynamic>>().map((e) => TeacherExamModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<TeacherExamModel> getExamDetail(int id) async {
    try {
      final response = await _dio.get(ApiEndpoints.teacherExamDetail(id));
      final data = response.data;
      final json = data is Map<String, dynamic> ? data['data'] as Map<String, dynamic>? ?? {} : <String, dynamic>{};
      return TeacherExamModel.fromJson(json);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<TeacherExamModel> createExam(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post(ApiEndpoints.teacherExams, data: body);
      final data = response.data;
      final json = data is Map<String, dynamic> ? data['data'] as Map<String, dynamic>? ?? {} : <String, dynamic>{};
      return TeacherExamModel.fromJson(json);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<TeacherExamModel> updateExam(int id, Map<String, dynamic> body) async {
    try {
      final response = await _dio.put(ApiEndpoints.teacherExamDetail(id), data: body);
      final data = response.data;
      final json = data is Map<String, dynamic> ? data['data'] as Map<String, dynamic>? ?? {} : <String, dynamic>{};
      return TeacherExamModel.fromJson(json);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> deleteExam(int id) async {
    try {
      await _dio.delete(ApiEndpoints.teacherExamDetail(id));
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<TeacherExamQuestionModel> createQuestion(int examId, Map<String, dynamic> body) async {
    try {
      final response = await _dio.post(ApiEndpoints.teacherExamQuestions(examId), data: body);
      final data = response.data;
      final json = data is Map<String, dynamic> ? data['data'] as Map<String, dynamic>? ?? {} : <String, dynamic>{};
      return TeacherExamQuestionModel.fromJson(json);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<TeacherExamQuestionModel> updateQuestion(int examId, int questionId, Map<String, dynamic> body) async {
    try {
      final response = await _dio.put(ApiEndpoints.teacherExamQuestionDetail(examId, questionId), data: body);
      final data = response.data;
      final json = data is Map<String, dynamic> ? data['data'] as Map<String, dynamic>? ?? {} : <String, dynamic>{};
      return TeacherExamQuestionModel.fromJson(json);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> deleteQuestion(int examId, int questionId) async {
    try {
      await _dio.delete(ApiEndpoints.teacherExamQuestionDetail(examId, questionId));
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Exception _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const NetworkException();
    }
    final statusCode = e.response?.statusCode;
    if (statusCode == 401) return const UnauthorizedException();
    if (statusCode == 422) {
      final data = e.response?.data;
      final message = data is Map<String, dynamic> ? data['message'] as String? : null;
      return ServerException(message ?? 'بيانات الامتحان غير صحيحة', statusCode: 422);
    }
    return ServerException(
      e.response?.data?['message'] as String? ?? 'حدث خطأ في السيرفر',
      statusCode: statusCode,
    );
  }
}
