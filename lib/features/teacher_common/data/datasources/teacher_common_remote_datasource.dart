import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/teacher_subject_model.dart';

abstract class TeacherCommonRemoteDataSource {
  Future<List<TeacherSubjectModel>> getClassSubjects(int classId);
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
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) throw const UnauthorizedException();
      throw ServerException(
        e.response?.data?['message'] as String? ?? 'حدث خطأ في السيرفر',
        statusCode: statusCode,
      );
    }
  }
}
