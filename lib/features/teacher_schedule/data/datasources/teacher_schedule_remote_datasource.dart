import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/teacher_schedule_models.dart';

abstract class TeacherScheduleRemoteDataSource {
  Future<List<TeacherDayScheduleModel>> getSchedule();
}

class TeacherScheduleRemoteDataSourceImpl implements TeacherScheduleRemoteDataSource {
  final Dio _dio;
  TeacherScheduleRemoteDataSourceImpl(this._dio);

  @override
  Future<List<TeacherDayScheduleModel>> getSchedule() async {
    try {
      final response = await _dio.get(ApiEndpoints.teacherSchedule);
      final data = response.data;
      List<dynamic> list;
      if (data is Map) list = (data['data'] ?? data['schedule'] ?? []) as List<dynamic>;
      else if (data is List) list = data;
      else list = [];
      return list.map((e) => TeacherDayScheduleModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) throw const NetworkException();
      throw ServerException(e.message ?? 'خطأ في الخادم');
    }
  }
}
