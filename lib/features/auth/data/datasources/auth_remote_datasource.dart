import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/student_model.dart';
import '../models/teacher_model.dart';

abstract class AuthRemoteDataSource {
  Future<({String token, StudentModel student})> loginStudent({
    required String nationalId,
    required String password,
  });

  Future<({String token, TeacherModel teacher})> loginTeacher({
    required String nationalId,
    required String password,
  });

  Future<({String token, StudentModel student})> switchSibling(int siblingId);

  Future<void> logout(String endpoint);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;
  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<({String token, StudentModel student})> loginStudent({
    required String nationalId,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.studentLogin,
        data: {'national_id': nationalId, 'password': password},
      );
      final data = _unwrap(response.data);
      return (
        token: data['token'] as String,
        student: StudentModel.fromJson(data['student'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      _handleDioError(e);
    }
    throw ServerException('خطأ غير متوقع');
  }

  @override
  Future<({String token, TeacherModel teacher})> loginTeacher({
    required String nationalId,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.teacherLogin,
        data: {'national_id': nationalId, 'password': password},
      );
      final data = _unwrap(response.data);
      return (
        token: data['token'] as String,
        teacher: TeacherModel.fromJson(data['teacher'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      _handleDioError(e);
    }
    throw ServerException('خطأ غير متوقع');
  }

  @override
  Future<({String token, StudentModel student})> switchSibling(int siblingId) async {
    try {
      final response = await _dio.post(ApiEndpoints.studentSwitchSibling(siblingId));
      final data = _unwrap(response.data);
      return (
        token: data['token'] as String,
        student: StudentModel.fromJson(data['student'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      _handleDioError(e);
    }
    throw ServerException('خطأ غير متوقع');
  }

  @override
  Future<void> logout(String endpoint) async {
    try {
      await _dio.post(endpoint);
    } catch (_) {}
  }

  Map<String, dynamic> _unwrap(dynamic responseData) {
    final body = responseData as Map<String, dynamic>;
    return body['data'] as Map<String, dynamic>? ?? body;
  }

  Never _handleDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    if (statusCode == 401) {
      throw AuthException(e.message ?? 'بيانات الدخول غير صحيحة');
    } else if (statusCode == 422) {
      final errors = _extractValidationErrors(e.response?.data);
      throw ValidationException(errors);
    } else if (e.type == DioExceptionType.connectionError) {
      throw const NetworkException();
    } else {
      throw ServerException(
        e.message ?? 'خطأ في الخادم',
        statusCode: statusCode,
      );
    }
  }

  Map<String, List<String>> _extractValidationErrors(dynamic data) {
    final result = <String, List<String>>{};
    if (data is Map) {
      final errors = data['errors'];
      if (errors is Map) {
        errors.forEach((key, value) {
          if (value is List) {
            result[key.toString()] = value.map((v) => v.toString()).toList();
          }
        });
      }
    }
    return result;
  }
}
