import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/teacher_attendance_models.dart';

abstract class TeacherAttendanceRemoteDataSource {
  Future<List<TeacherAttendanceClassModel>> getClasses();
  Future<List<AttendanceEntryModel>> getStudents(int classId);
  Future<void> submitAttendance({
    required int classId,
    required String date,
    required List<Map<String, dynamic>> entries,
  });
}

class TeacherAttendanceRemoteDataSourceImpl implements TeacherAttendanceRemoteDataSource {
  final Dio _dio;
  TeacherAttendanceRemoteDataSourceImpl(this._dio);

  @override
  Future<List<TeacherAttendanceClassModel>> getClasses() async {
    try {
      final response = await _dio.get(ApiEndpoints.teacherAttendanceClasses);
      final data = response.data;
      List<dynamic> list;
      if (data is Map) list = (data['data'] ?? data['classes'] ?? []) as List<dynamic>;
      else if (data is List) list = data;
      else list = [];
      return list.map((e) => TeacherAttendanceClassModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) throw const NetworkException();
      throw ServerException(e.message ?? 'خطأ في الخادم');
    }
  }

  @override
  Future<List<AttendanceEntryModel>> getStudents(int classId) async {
    try {
      final response = await _dio.get(ApiEndpoints.teacherAttendanceStudents(classId));
      final data = response.data;
      List<dynamic> list;
      if (data is Map) list = (data['data'] ?? data['students'] ?? []) as List<dynamic>;
      else if (data is List) list = data;
      else list = [];
      return list.map((e) => AttendanceEntryModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) throw const NetworkException();
      throw ServerException(e.message ?? 'خطأ في الخادم');
    }
  }

  @override
  Future<void> submitAttendance({
    required int classId,
    required String date,
    required List<Map<String, dynamic>> entries,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.teacherSubmitAttendance,
        data: {'class_id': classId, 'date': date, 'attendance': entries},
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) throw const NetworkException();
      throw ServerException(e.message ?? 'خطأ في الخادم');
    }
  }
}
