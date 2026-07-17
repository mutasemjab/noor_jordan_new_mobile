import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/announcement_model.dart';

abstract class AnnouncementsRemoteDataSource {
  Future<List<AnnouncementModel>> getAnnouncements({int page, bool isTeacher});
  Future<AnnouncementModel> getAnnouncementDetail(int id, {bool isTeacher});
}

class AnnouncementsRemoteDataSourceImpl implements AnnouncementsRemoteDataSource {
  final Dio _dio;
  AnnouncementsRemoteDataSourceImpl(this._dio);

  @override
  Future<List<AnnouncementModel>> getAnnouncements({int page = 1, bool isTeacher = false}) async {
    try {
      final endpoint = isTeacher ? ApiEndpoints.teacherAnnouncements : ApiEndpoints.studentAnnouncements;
      final response = await _dio.get(endpoint, queryParameters: {'page': page});
      final data = response.data;
      List<dynamic> list;
      if (data is Map) {
        list = (data['data'] ?? data['announcements'] ?? []) as List<dynamic>;
      } else if (data is List) {
        list = data;
      } else {
        list = [];
      }
      return list.map((e) => AnnouncementModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) throw const NetworkException();
      throw ServerException(e.message ?? 'خطأ في الخادم');
    }
  }

  @override
  Future<AnnouncementModel> getAnnouncementDetail(int id, {bool isTeacher = false}) async {
    try {
      final endpoint = isTeacher
          ? ApiEndpoints.teacherAnnouncementDetail(id)
          : ApiEndpoints.studentAnnouncementDetail(id);
      final response = await _dio.get(endpoint);
      final data = response.data;
      final item = data is Map && data['data'] != null ? data['data'] : data;
      return AnnouncementModel.fromJson(item as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) throw const NetworkException();
      throw ServerException(e.message ?? 'خطأ في الخادم');
    }
  }
}
