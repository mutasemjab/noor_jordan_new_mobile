import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/attendance_models.dart';

abstract class AttendanceRemoteDataSource {
  Future<AttendanceDataModel> getAttendance();
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final Dio _dio;

  AttendanceRemoteDataSourceImpl(this._dio);

  @override
  Future<AttendanceDataModel> getAttendance() async {
    try {
      final response = await _dio.get(ApiEndpoints.studentAttendance);
      final data = response.data;

      Map<String, dynamic> payload;
      if (data is Map<String, dynamic> && data.containsKey('data')) {
        payload = data['data'] as Map<String, dynamic>;
      } else if (data is Map<String, dynamic>) {
        payload = data;
      } else {
        payload = {};
      }

      return AttendanceDataModel.fromJson(payload);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }
      throw ServerException(
        e.response?.data?['message'] as String? ?? 'حدث خطأ في السيرفر',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
