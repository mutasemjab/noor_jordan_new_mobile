import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/teacher_video_model.dart';

abstract class TeacherVideosRemoteDataSource {
  Future<List<TeacherVideoModel>> getClassVideos(int classId);

  Future<void> createVideo({
    required int classId,
    required int subjectId,
    required String title,
    required String youtubeUrl,
  });

  Future<void> deleteVideo({required int classId, required int videoId});
}

class TeacherVideosRemoteDataSourceImpl implements TeacherVideosRemoteDataSource {
  final Dio _dio;
  TeacherVideosRemoteDataSourceImpl(this._dio);

  @override
  Future<List<TeacherVideoModel>> getClassVideos(int classId) async {
    try {
      final response = await _dio.get(ApiEndpoints.teacherClassVideos(classId));
      final data = response.data;
      final list = data is Map<String, dynamic> ? data['data'] as List<dynamic>? ?? [] : <dynamic>[];
      return list.whereType<Map<String, dynamic>>().map((e) => TeacherVideoModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> createVideo({
    required int classId,
    required int subjectId,
    required String title,
    required String youtubeUrl,
  }) async {
    try {
      await _dio.post(ApiEndpoints.teacherClassVideos(classId), data: {
        'subject_id': subjectId,
        'title': title,
        'youtube_url': youtubeUrl,
      });
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> deleteVideo({required int classId, required int videoId}) async {
    try {
      await _dio.delete(ApiEndpoints.teacherDeleteVideo(classId, videoId));
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
