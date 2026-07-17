import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/subject_model.dart';
import '../models/subject_video_model.dart';

abstract class SubjectsRemoteDataSource {
  Future<List<SubjectModel>> getSubjects();
  Future<List<SubjectVideoModel>> getSubjectVideos(int subjectId);
}

class SubjectsRemoteDataSourceImpl implements SubjectsRemoteDataSource {
  final Dio dio;
  SubjectsRemoteDataSourceImpl(this.dio);

  @override
  Future<List<SubjectModel>> getSubjects() async {
    try {
      final response = await dio.get(ApiEndpoints.studentSubjects);
      final data = response.data;
      List<dynamic> subjectsJson;
      if (data is Map<String, dynamic> && data['subjects'] != null) {
        subjectsJson = data['subjects'] as List<dynamic>;
      } else if (data is List) {
        subjectsJson = data;
      } else if (data is Map<String, dynamic> && data['data'] != null) {
        final inner = data['data'];
        if (inner is Map<String, dynamic> && inner['subjects'] != null) {
          subjectsJson = inner['subjects'] as List<dynamic>;
        } else if (inner is List) {
          subjectsJson = inner;
        } else {
          subjectsJson = [];
        }
      } else {
        subjectsJson = [];
      }
      return subjectsJson
          .map((e) => SubjectModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw const NetworkException();
      }
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) throw const UnauthorizedException();
      if (statusCode == 404) throw const NotFoundException();
      throw ServerException(
        e.response?.data?['message'] as String? ?? 'حدث خطأ في الخادم',
        statusCode: statusCode,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<SubjectVideoModel>> getSubjectVideos(int subjectId) async {
    try {
      final response = await dio.get(ApiEndpoints.studentSubjectVideos(subjectId));
      final data = response.data;
      List<dynamic> videosJson;
      if (data is List) {
        videosJson = data;
      } else if (data is Map<String, dynamic> && data['data'] != null) {
        final inner = data['data'];
        videosJson = inner is List ? inner : [];
      } else {
        videosJson = [];
      }
      return videosJson
          .map((e) => SubjectVideoModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw const NetworkException();
      }
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) throw const UnauthorizedException();
      if (statusCode == 404) throw const NotFoundException();
      throw ServerException(
        e.response?.data?['message'] as String? ?? 'حدث خطأ في الخادم',
        statusCode: statusCode,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
