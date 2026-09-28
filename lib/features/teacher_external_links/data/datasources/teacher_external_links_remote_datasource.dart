import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/teacher_external_link_model.dart';

abstract class TeacherExternalLinksRemoteDataSource {
  Future<List<TeacherExternalLinkModel>> getLinks({int? classId, int? subjectId});

  Future<void> createLink({required int classId, required int subjectId, required String url});

  Future<void> updateLink({required int id, required String url});

  Future<void> deleteLink(int id);
}

class TeacherExternalLinksRemoteDataSourceImpl implements TeacherExternalLinksRemoteDataSource {
  final Dio _dio;
  TeacherExternalLinksRemoteDataSourceImpl(this._dio);

  @override
  Future<List<TeacherExternalLinkModel>> getLinks({int? classId, int? subjectId}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.teacherExternalLinks,
        queryParameters: {
          if (classId != null) 'class_id': classId,
          if (subjectId != null) 'subject_id': subjectId,
        },
      );
      final data = response.data;
      final list = data is Map<String, dynamic> ? data['data'] as List<dynamic>? ?? [] : <dynamic>[];
      return list.whereType<Map<String, dynamic>>().map(TeacherExternalLinkModel.fromJson).toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> createLink({required int classId, required int subjectId, required String url}) async {
    try {
      await _dio.post(ApiEndpoints.teacherExternalLinks, data: {
        'class_id': classId,
        'subject_id': subjectId,
        'url': url,
      });
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> updateLink({required int id, required String url}) async {
    try {
      await _dio.put(ApiEndpoints.teacherExternalLinkDetail(id), data: {'url': url});
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> deleteLink(int id) async {
    try {
      await _dio.delete(ApiEndpoints.teacherExternalLinkDetail(id));
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
    if (statusCode == 403) {
      return ServerException(e.response?.data?['message'] as String? ?? 'غير مصرح لك بهذا الإجراء', statusCode: 403);
    }
    return ServerException(
      e.response?.data?['message'] as String? ?? 'حدث خطأ في السيرفر',
      statusCode: statusCode,
    );
  }
}
