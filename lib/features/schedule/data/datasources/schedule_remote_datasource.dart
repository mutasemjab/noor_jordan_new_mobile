import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/schedule_models.dart';

abstract class ScheduleRemoteDataSource {
  Future<ClassScheduleModel> getSchedule();
}

class ScheduleRemoteDataSourceImpl implements ScheduleRemoteDataSource {
  final Dio _dio;

  ScheduleRemoteDataSourceImpl(this._dio);

  @override
  Future<ClassScheduleModel> getSchedule() async {
    try {
      final response = await _dio.get(ApiEndpoints.studentSchedule);
      final data = response.data;

      Map<String, dynamic> payload;
      if (data is Map<String, dynamic> && data.containsKey('data')) {
        payload = data['data'] as Map<String, dynamic>? ?? {};
      } else if (data is Map<String, dynamic>) {
        payload = data;
      } else {
        payload = {};
      }

      return ClassScheduleModel.fromJson(payload);
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
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
