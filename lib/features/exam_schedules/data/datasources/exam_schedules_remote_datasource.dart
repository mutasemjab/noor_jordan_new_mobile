import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/exam_schedule_model.dart';

abstract class ExamSchedulesRemoteDataSource {
  Future<List<ExamScheduleModel>> getExamSchedules();
}

class ExamSchedulesRemoteDataSourceImpl implements ExamSchedulesRemoteDataSource {
  final Dio _dio;

  ExamSchedulesRemoteDataSourceImpl(this._dio);

  @override
  Future<List<ExamScheduleModel>> getExamSchedules() async {
    try {
      final response = await _dio.get(ApiEndpoints.studentExamSchedules);
      final data = response.data;

      List<dynamic> list;
      if (data is Map<String, dynamic> && data.containsKey('data')) {
        list = data['data'] as List<dynamic>? ?? [];
      } else if (data is List<dynamic>) {
        list = data;
      } else {
        list = [];
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map((e) => ExamScheduleModel.fromJson(e))
          .toList();
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
