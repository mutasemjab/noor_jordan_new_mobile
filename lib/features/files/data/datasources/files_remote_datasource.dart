import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/file_item_model.dart';

abstract class FilesRemoteDataSource {
  Future<List<FileItemModel>> getPreviousExams();
  Future<List<FileItemModel>> getQuestionBanks();
  Future<List<FileItemModel>> getWorksheets();
}

class FilesRemoteDataSourceImpl implements FilesRemoteDataSource {
  final Dio _dio;

  FilesRemoteDataSourceImpl(this._dio);

  List<FileItemModel> _parseList(dynamic data) {
    List<dynamic> list;
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      list = data['data'] as List<dynamic>? ?? [];
    } else if (data is List<dynamic>) {
      list = data;
    } else {
      list = [];
    }
    return list
        .map((e) => FileItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<FileItemModel>> _fetchList(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      return _parseList(response.data);
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

  @override
  Future<List<FileItemModel>> getPreviousExams() =>
      _fetchList(ApiEndpoints.studentPreviousExams);

  @override
  Future<List<FileItemModel>> getQuestionBanks() =>
      _fetchList(ApiEndpoints.studentQuestionBanks);

  @override
  Future<List<FileItemModel>> getWorksheets() =>
      _fetchList(ApiEndpoints.studentWorksheets);
}
