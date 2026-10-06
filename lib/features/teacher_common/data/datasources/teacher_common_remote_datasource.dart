import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/day_period_model.dart';
import '../models/teacher_subject_model.dart';

abstract class TeacherCommonRemoteDataSource {
  Future<List<TeacherSubjectModel>> getClassSubjects(int classId);

  Future<List<ClassDayPeriodModel>> getClassDaySchedule({required int classId, required String date});
}

class TeacherCommonRemoteDataSourceImpl implements TeacherCommonRemoteDataSource {
  final Dio _dio;
  TeacherCommonRemoteDataSourceImpl(this._dio);

  @override
  Future<List<TeacherSubjectModel>> getClassSubjects(int classId) async {
    try {
      final response = await _dio.get(ApiEndpoints.teacherClassSubjects(classId));
      final data = response.data;
      final list = data is Map<String, dynamic> ? data['data'] as List<dynamic>? ?? [] : <dynamic>[];
      return list.whereType<Map<String, dynamic>>().map((e) => TeacherSubjectModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<List<ClassDayPeriodModel>> getClassDaySchedule({required int classId, required String date}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.teacherClassDaySchedule(classId),
        queryParameters: {'date': date},
      );
      final data = response.data;
      final list = data is Map<String, dynamic> ? data['data'] as List<dynamic>? ?? [] : <dynamic>[];
      return list.whereType<Map<String, dynamic>>().map((e) => ClassDayPeriodModel.fromJson(e)).toList();
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
