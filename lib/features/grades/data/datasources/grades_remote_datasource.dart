import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/grades_models.dart';

abstract class GradesRemoteDataSource {
  Future<List<SubjectGradesModel>> getGrades();
}

class GradesRemoteDataSourceImpl implements GradesRemoteDataSource {
  final Dio _dio;

  GradesRemoteDataSourceImpl(this._dio);

  @override
  Future<List<SubjectGradesModel>> getGrades() async {
    try {
      final response = await _dio.get(ApiEndpoints.studentGrades);
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
          .map((e) => SubjectGradesModel.fromJson(e as Map<String, dynamic>))
          .toList();
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
