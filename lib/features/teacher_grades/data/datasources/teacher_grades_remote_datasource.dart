import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/teacher_grades_models.dart';

abstract class TeacherGradesRemoteDataSource {
  Future<List<GradeClassModel>> getClasses();
  Future<List<GradeExamTypeModel>> getExamTypes(int classId);
  Future<List<StudentGradeEntryModel>> getStudentGrades(int classId, int examTypeId);
  Future<void> submitGrades({
    required int classId,
    required int examTypeId,
    required List<Map<String, dynamic>> grades,
  });
}

class TeacherGradesRemoteDataSourceImpl implements TeacherGradesRemoteDataSource {
  final Dio _dio;
  TeacherGradesRemoteDataSourceImpl(this._dio);

  List<dynamic> _extractList(dynamic data, List<String> keys) {
    if (data is List) return data;
    if (data is Map) {
      for (final key in keys) {
        if (data[key] != null) return data[key] as List<dynamic>;
      }
    }
    return [];
  }

  @override
  Future<List<GradeClassModel>> getClasses() async {
    try {
      final response = await _dio.get(ApiEndpoints.teacherGradeClasses);
      final list = _extractList(response.data, ['data', 'classes']);
      return list.map((e) => GradeClassModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) throw const NetworkException();
      throw ServerException(e.message ?? 'خطأ في الخادم');
    }
  }

  @override
  Future<List<GradeExamTypeModel>> getExamTypes(int classId) async {
    try {
      final response = await _dio.get(ApiEndpoints.teacherGradeExamTypes(classId));
      final list = _extractList(response.data, ['data', 'exam_types', 'examTypes']);
      return list.map((e) => GradeExamTypeModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) throw const NetworkException();
      throw ServerException(e.message ?? 'خطأ في الخادم');
    }
  }

  @override
  Future<List<StudentGradeEntryModel>> getStudentGrades(int classId, int examTypeId) async {
    try {
      final response = await _dio.get(ApiEndpoints.teacherGradeStudents(classId, examTypeId));
      final list = _extractList(response.data, ['data', 'students']);
      return list.map((e) => StudentGradeEntryModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) throw const NetworkException();
      throw ServerException(e.message ?? 'خطأ في الخادم');
    }
  }

  @override
  Future<void> submitGrades({
    required int classId,
    required int examTypeId,
    required List<Map<String, dynamic>> grades,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.teacherSubmitGrades,
        data: {'class_id': classId, 'exam_type_id': examTypeId, 'grades': grades},
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) throw const NetworkException();
      throw ServerException(e.message ?? 'خطأ في الخادم');
    }
  }
}
