import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/student_trip_model.dart';

abstract class StudentTripRemoteDataSource {
  Future<StudentTripModel?> getMyTrip();
}

class StudentTripRemoteDataSourceImpl implements StudentTripRemoteDataSource {
  final Dio _dio;
  StudentTripRemoteDataSourceImpl(this._dio);

  @override
  Future<StudentTripModel?> getMyTrip() async {
    try {
      final response = await _dio.get(ApiEndpoints.studentMyTrip);
      final data = response.data;
      final json = data is Map<String, dynamic> ? data['data'] as Map<String, dynamic>? ?? {} : <String, dynamic>{};
      final tripJson = json['trip'] as Map<String, dynamic>?;
      return tripJson != null ? StudentTripModel.fromJson(tripJson) : null;
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
