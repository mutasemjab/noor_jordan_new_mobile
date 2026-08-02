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
      final homeResponse = await _dio.get(ApiEndpoints.teacherHome);
      if (homeResponse.statusCode != 200) {
        throw ServerException(
          'فشل تحميل بيانات الرئيسية',
          statusCode: homeResponse.statusCode,
        );
      }

      final classesResponse = await _dio.get(ApiEndpoints.teacherClasses);
      if (classesResponse.statusCode != 200) {
        throw ServerException(
          'فشل تحميل الصفوف',
          statusCode: classesResponse.statusCode,
        );
      }

      // Banners are best-effort: an older backend without this endpoint
      // shouldn't block the rest of the home screen from loading.
      List<dynamic> bannersJson = [];
      try {
        final bannersResponse = await _dio.get(ApiEndpoints.teacherBanners);
        final bannersData = bannersResponse.data;
        if (bannersData is Map<String, dynamic>) {
          bannersJson = bannersData['data'] as List<dynamic>? ?? [];
        } else if (bannersData is List<dynamic>) {
          bannersJson = bannersData;
        }
      } catch (_) {}

      final homeData = homeResponse.data;
      final homeJson = homeData is Map<String, dynamic>
          ? (homeData['data'] as Map<String, dynamic>? ?? homeData)
          : <String, dynamic>{};

      final classesData = classesResponse.data;
      final List<dynamic> classesJson;
      if (classesData is Map) {
        classesJson = (classesData['data'] ?? classesData['classes'] ?? []) as List<dynamic>;
      } else if (classesData is List) {
        classesJson = classesData;
      } else {
        classesJson = [];
      }

      return TeacherHomeDataModel.fromJson(
        homeJson: homeJson,
        bannersJson: bannersJson,
        classesJson: classesJson,
      );
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
