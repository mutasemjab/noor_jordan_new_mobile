import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/note_browse_models.dart';

abstract class NotesRemoteDataSource {
  Future<List<NoteDateSummaryModel>> getDates();
  Future<List<NoteSubjectModel>> getSubjects(String date);
  Future<List<NoteContentItemModel>> getContent({required String date, required int subjectId});
}

class NotesRemoteDataSourceImpl implements NotesRemoteDataSource {
  final Dio _dio;
  NotesRemoteDataSourceImpl(this._dio);

  List<dynamic> _unwrap(dynamic data) {
    if (data is Map) return (data['data'] ?? []) as List<dynamic>;
    if (data is List) return data;
    return [];
  }

  @override
  Future<List<NoteDateSummaryModel>> getDates() async {
    try {
      final response = await _dio.get(ApiEndpoints.studentNoteDates);
      return _unwrap(response.data)
          .whereType<Map<String, dynamic>>()
          .map(NoteDateSummaryModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<List<NoteSubjectModel>> getSubjects(String date) async {
    try {
      final response = await _dio.get(ApiEndpoints.studentNoteSubjects, queryParameters: {'date': date});
      return _unwrap(response.data)
          .whereType<Map<String, dynamic>>()
          .map(NoteSubjectModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<List<NoteContentItemModel>> getContent({required String date, required int subjectId}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.studentNoteContent,
        queryParameters: {'date': date, 'subject_id': subjectId},
      );
      return _unwrap(response.data)
          .whereType<Map<String, dynamic>>()
          .map(NoteContentItemModel.fromJson)
          .toList();
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
