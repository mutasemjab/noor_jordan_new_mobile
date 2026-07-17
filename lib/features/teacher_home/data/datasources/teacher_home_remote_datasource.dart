import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/teacher_home_models.dart';

abstract class TeacherHomeRemoteDataSource {
  Future<TeacherHomeDataModel> getHome();
}

class TeacherHomeRemoteDataSourceImpl implements TeacherHomeRemoteDataSource {
  final Dio _dio;

  TeacherHomeRemoteDataSourceImpl(this._dio);

  @override
  Future<TeacherHomeDataModel> getHome() async {
    try {
      final response = await _dio.get(ApiEndpoints.teacherHome);
      if (response.statusCode != 200) {
        throw ServerException(
          'فشل تحميل بيانات الرئيسية',
          statusCode: response.statusCode,
        );
      }
      final raw = response.data;
      final json = raw is Map<String, dynamic>
          ? (raw['data'] as Map<String, dynamic>? ?? raw)
          : <String, dynamic>{};
      return TeacherHomeDataModel.fromJson(json);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) throw const UnauthorizedException();
      throw ServerException(
        e.response?.data?['message'] as String? ?? 'حدث خطأ في الاتصال',
        statusCode: statusCode,
      );
    }
  }
}
