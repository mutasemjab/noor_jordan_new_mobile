import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/schedule_models.dart';

abstract class ScheduleRemoteDataSource {
  Future<List<DayScheduleModel>> getSchedule();
}

class ScheduleRemoteDataSourceImpl implements ScheduleRemoteDataSource {
  final Dio _dio;

  ScheduleRemoteDataSourceImpl(this._dio);

  @override
  Future<List<DayScheduleModel>> getSchedule() async {
    try {
      final response = await _dio.get(ApiEndpoints.studentSchedule);

      if (response.statusCode != 200) {
        throw ServerException(
          'فشل تحميل الجدول الدراسي',
          statusCode: response.statusCode,
        );
      }

      final responseData = response.data;
      List<dynamic> raw;

      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'];
        if (data is List<dynamic>) {
          raw = data;
        } else if (data is Map<String, dynamic>) {
          raw = data.values.toList();
        } else {
          raw = [];
        }
      } else if (responseData is List<dynamic>) {
        raw = responseData;
      } else {
        raw = [];
      }

      return raw
          .whereType<Map<String, dynamic>>()
          .map((e) => DayScheduleModel.fromJson(e))
          .toList();
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
