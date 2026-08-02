import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/class_models.dart';

abstract class ClassesRemoteDataSource {
  Future<List<SchoolClassModel>> getClasses();
  Future<List<ClassStudentModel>> getClassStudents(int classId);
}

class ClassesRemoteDataSourceImpl implements ClassesRemoteDataSource {
  final Dio _dio;
  ClassesRemoteDataSourceImpl(this._dio);

  @override
  Future<List<SchoolClassModel>> getClasses() async {
    try {
      final response = await _dio.get(ApiEndpoints.teacherClasses);
      final data = response.data;
      List<dynamic> list;
      if (data is Map) list = (data['data'] ?? data['classes'] ?? []) as List<dynamic>;
      else if (data is List) list = data;
      else list = [];
      return list.map((e) => SchoolClassModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) throw const NetworkException();
      throw ServerException(e.message ?? 'خطأ في الخادم');
    }
  }

  @override
  Future<List<ClassStudentModel>> getClassStudents(int classId) async {
    try {
      final response = await _dio.get(ApiEndpoints.teacherClassStudents(classId));
      final data = response.data;
      List<dynamic> list;
      if (data is Map) {
        final inner = data['data'];
        if (inner is List) {
          list = inner;
        } else if (inner is Map && inner['students'] is List) {
          list = inner['students'] as List<dynamic>;
        } else if (data['students'] is List) {
          list = data['students'] as List<dynamic>;
        } else {
          list = [];
        }
      } else if (data is List) {
        list = data;
      } else {
        list = [];
      }
      return list.map((e) => ClassStudentModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) throw const NetworkException();
      throw ServerException(e.message ?? 'خطأ في الخادم');
    }
  }
}
