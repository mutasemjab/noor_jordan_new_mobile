import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/external_link_model.dart';

abstract class ExternalLinksRemoteDataSource {
  Future<List<ExternalLinkModel>> getExternalLinks();
}

class ExternalLinksRemoteDataSourceImpl implements ExternalLinksRemoteDataSource {
  final Dio _dio;
  ExternalLinksRemoteDataSourceImpl(this._dio);

  @override
  Future<List<ExternalLinkModel>> getExternalLinks() async {
    try {
      final response = await _dio.get(ApiEndpoints.studentExternalLinks);
      final data = response.data;
      final list = data is Map<String, dynamic> ? data['data'] as List<dynamic>? ?? [] : <dynamic>[];
      return list.whereType<Map<String, dynamic>>().map(ExternalLinkModel.fromJson).toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Exception _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const NetworkException();
    }
    final statusCode = e.response?.statusCode;
    if (statusCode == 401) return const UnauthorizedException();
    return ServerException(
      e.response?.data?['message'] as String? ?? 'حدث خطأ في السيرفر',
      statusCode: statusCode,
    );
  }
}
