import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/home_models.dart';

abstract class HomeRemoteDataSource {
  Future<StudentHomeDataModel> getStudentHome();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio _dio;

  HomeRemoteDataSourceImpl(this._dio);

  @override
  Future<StudentHomeDataModel> getStudentHome() async {
    try {
      final results = await Future.wait([
        _dio.get(ApiEndpoints.studentHome),
        _dio.get(ApiEndpoints.studentBanners),
      ]);

      final homeResponse = results[0];
      final bannersResponse = results[1];

      if (homeResponse.statusCode != 200) {
        throw ServerException(
          'فشل تحميل بيانات الرئيسية',
          statusCode: homeResponse.statusCode,
        );
      }

      if (bannersResponse.statusCode != 200) {
        throw ServerException(
          'فشل تحميل الإعلانات',
          statusCode: bannersResponse.statusCode,
        );
      }

      final homeData = homeResponse.data;
      final homeJson = homeData is Map<String, dynamic>
          ? (homeData['data'] as Map<String, dynamic>? ?? homeData)
          : <String, dynamic>{};

      final bannersData = bannersResponse.data;
      final List<dynamic> bannersJson;
      if (bannersData is Map<String, dynamic>) {
        bannersJson = bannersData['data'] as List<dynamic>? ?? [];
      } else if (bannersData is List<dynamic>) {
        bannersJson = bannersData;
      } else {
        bannersJson = [];
      }

      return StudentHomeDataModel.fromJson(
        homeJson: homeJson,
        bannersJson: bannersJson,
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
