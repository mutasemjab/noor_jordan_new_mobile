import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/teacher_grades_models.dart';

abstract class TeacherGradesRemoteDataSource {
  Future<List<GradeRecordModel>> getGrades({
    required int classId,
    required int subjectId,
    String? title,
  });

  Future<void> submitGrades(Map<String, dynamic> body);
}

class TeacherGradesRemoteDataSourceImpl implements TeacherGradesRemoteDataSource {
  final Dio _dio;
  TeacherGradesRemoteDataSourceImpl(this._dio);

  @override
  Future<List<GradeRecordModel>> getGrades({
    required int classId,
    required int subjectId,
    String? title,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.teacherGrades,
        queryParameters: {
          'class_id': classId,
          'subject_id': subjectId,
          if (title != null && title.isNotEmpty) 'title': title,
        },
      );
      final data = response.data;
      final list = data is Map<String, dynamic> ? data['data'] as List<dynamic>? ?? [] : <dynamic>[];
      return list.whereType<Map<String, dynamic>>().map((e) => GradeRecordModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> submitGrades(Map<String, dynamic> body) async {
    try {
      await _dio.post(ApiEndpoints.teacherGrades, data: body);
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
    return ServerException(
      e.response?.data?['message'] as String? ?? 'حدث خطأ في السيرفر',
      statusCode: statusCode,
    );
  }
}
