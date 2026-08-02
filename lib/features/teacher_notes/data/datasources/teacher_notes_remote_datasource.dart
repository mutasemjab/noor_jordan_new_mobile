import 'dart:io';

import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../educational_notes/data/models/note_model.dart';
import '../../../educational_notes/domain/entities/educational_note.dart';

abstract class TeacherNotesRemoteDataSource {
  Future<List<NoteModel>> getClassNotes(int classId);

  Future<void> createNote({
    required int classId,
    required String title,
    required String description,
    required EducationalNoteType type,
    required DateTime date,
    File? attachment,
  });

  Future<void> updateNote({
    required int noteId,
    required String title,
    required String description,
    required EducationalNoteType type,
    required DateTime date,
    File? attachment,
  });

  Future<void> deleteNote(int noteId);
}

class TeacherNotesRemoteDataSourceImpl implements TeacherNotesRemoteDataSource {
  final Dio _dio;
  TeacherNotesRemoteDataSourceImpl(this._dio);

  String _dateStr(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Future<List<NoteModel>> getClassNotes(int classId) async {
    try {
      final response = await _dio.get(ApiEndpoints.teacherClassNotes(classId));
      final data = response.data;
      final list = data is Map<String, dynamic> ? data['data'] as List<dynamic>? ?? [] : <dynamic>[];
      return list.whereType<Map<String, dynamic>>().map((e) => NoteModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> createNote({
    required int classId,
    required String title,
    required String description,
    required EducationalNoteType type,
    required DateTime date,
    File? attachment,
  }) async {
    try {
      final formData = FormData.fromMap({
        'class_id': classId,
        'title': title,
        'description': description,
        'type': type.name,
        'date': _dateStr(date),
        if (attachment != null)
          'attachment': await MultipartFile.fromFile(
            attachment.path,
            filename: attachment.path.split(Platform.pathSeparator).last,
          ),
      });
      await _dio.post(ApiEndpoints.teacherCreateNote, data: formData);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> updateNote({
    required int noteId,
    required String title,
    required String description,
    required EducationalNoteType type,
    required DateTime date,
    File? attachment,
  }) async {
    try {
      final formData = FormData.fromMap({
        '_method': 'PUT',
        'title': title,
        'description': description,
        'type': type.name,
        'date': _dateStr(date),
        if (attachment != null)
          'attachment': await MultipartFile.fromFile(
            attachment.path,
            filename: attachment.path.split(Platform.pathSeparator).last,
          ),
      });
      await _dio.post(ApiEndpoints.teacherUpdateNote(noteId), data: formData);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> deleteNote(int noteId) async {
    try {
      await _dio.delete(ApiEndpoints.teacherDeleteNote(noteId));
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
