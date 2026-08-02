import 'dart:io';

import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/teacher_file_item.dart';
import '../models/teacher_file_item_model.dart';

abstract class TeacherFilesRemoteDataSource {
  Future<List<TeacherFileItemModel>> getFiles({required TeacherFileKind kind, int? classId, int? subjectId});

  Future<void> createFile({
    required TeacherFileKind kind,
    required int classId,
    required int subjectId,
    required String title,
    int? year,
    required File file,
  });

  Future<void> updateFile({
    required TeacherFileKind kind,
    required int id,
    required String title,
    int? year,
    File? file,
  });

  Future<void> deleteFile({required TeacherFileKind kind, required int id});
}

class TeacherFilesRemoteDataSourceImpl implements TeacherFilesRemoteDataSource {
  final Dio _dio;
  TeacherFilesRemoteDataSourceImpl(this._dio);

  String _listCreateEndpoint(TeacherFileKind kind) {
    switch (kind) {
      case TeacherFileKind.questionBank:
        return ApiEndpoints.teacherQuestionBanks;
      case TeacherFileKind.previousYearExam:
        return ApiEndpoints.teacherPreviousYearExams;
      case TeacherFileKind.worksheet:
        return ApiEndpoints.teacherWorksheets;
    }
  }

  String _detailEndpoint(TeacherFileKind kind, int id) {
    switch (kind) {
      case TeacherFileKind.questionBank:
        return ApiEndpoints.teacherQuestionBankDetail(id);
      case TeacherFileKind.previousYearExam:
        return ApiEndpoints.teacherPreviousYearExamDetail(id);
      case TeacherFileKind.worksheet:
        return ApiEndpoints.teacherWorksheetDetail(id);
    }
  }

  @override
  Future<List<TeacherFileItemModel>> getFiles({required TeacherFileKind kind, int? classId, int? subjectId}) async {
    try {
      final response = await _dio.get(
        _listCreateEndpoint(kind),
        queryParameters: {
          if (classId != null) 'class_id': classId,
          if (subjectId != null) 'subject_id': subjectId,
        },
      );
      final data = response.data;
      final list = data is Map<String, dynamic> ? data['data'] as List<dynamic>? ?? [] : <dynamic>[];
      return list.whereType<Map<String, dynamic>>().map((e) => TeacherFileItemModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> createFile({
    required TeacherFileKind kind,
    required int classId,
    required int subjectId,
    required String title,
    int? year,
    required File file,
  }) async {
    try {
      final formData = FormData.fromMap({
        'class_id': classId,
        'subject_id': subjectId,
        'title': title,
        if (year != null) 'year': year,
        'file': await MultipartFile.fromFile(file.path, filename: file.path.split(Platform.pathSeparator).last),
      });
      await _dio.post(_listCreateEndpoint(kind), data: formData);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> updateFile({
    required TeacherFileKind kind,
    required int id,
    required String title,
    int? year,
    File? file,
  }) async {
    try {
      final formData = FormData.fromMap({
        '_method': 'PUT',
        'title': title,
        if (year != null) 'year': year,
        if (file != null) 'file': await MultipartFile.fromFile(file.path, filename: file.path.split(Platform.pathSeparator).last),
      });
      await _dio.post(_detailEndpoint(kind, id), data: formData);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> deleteFile({required TeacherFileKind kind, required int id}) async {
    try {
      await _dio.delete(_detailEndpoint(kind, id));
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
    if (statusCode == 403) return ServerException(e.response?.data?['message'] as String? ?? 'غير مصرح لك بهذا الإجراء', statusCode: 403);
    return ServerException(
      e.response?.data?['message'] as String? ?? 'حدث خطأ في السيرفر',
      statusCode: statusCode,
    );
  }
}
