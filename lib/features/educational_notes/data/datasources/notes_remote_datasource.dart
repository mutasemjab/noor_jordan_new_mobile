import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/note_model.dart';

abstract class NotesRemoteDataSource {
  Future<List<NoteModel>> getNotes();
}

class NotesRemoteDataSourceImpl implements NotesRemoteDataSource {
  final Dio _dio;
  NotesRemoteDataSourceImpl(this._dio);

  @override
  Future<List<NoteModel>> getNotes() async {
    try {
      final response = await _dio.get(ApiEndpoints.studentEducationalNotes);
      final data = response.data;
      List<dynamic> list;
      if (data is Map) {
        list = (data['data'] ?? data['notes'] ?? []) as List<dynamic>;
      } else if (data is List) {
        list = data;
      } else {
        list = [];
      }
      return list.map((e) => NoteModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) throw const NetworkException();
      throw ServerException(e.message ?? 'خطأ في الخادم');
    }
  }
}
