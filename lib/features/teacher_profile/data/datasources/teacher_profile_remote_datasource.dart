import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/teacher_profile_model.dart';

abstract class TeacherProfileRemoteDataSource {
  Future<TeacherProfileModel> getProfile();
  Future<TeacherProfileModel> updateProfile({
    required String name,
    required String phone,
    String? avatarPath,
  });
}

class TeacherProfileRemoteDataSourceImpl implements TeacherProfileRemoteDataSource {
  final Dio _dio;
  TeacherProfileRemoteDataSourceImpl(this._dio);

  @override
  Future<TeacherProfileModel> getProfile() async {
    try {
      final response = await _dio.get(ApiEndpoints.teacherProfile);
      final data = response.data is Map && response.data['data'] != null
          ? response.data['data'] as Map<String, dynamic>
          : response.data as Map<String, dynamic>;
      return TeacherProfileModel.fromJson(data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) throw const NetworkException();
      throw ServerException(e.message ?? 'خطأ في الخادم');
    }
  }

  @override
  Future<TeacherProfileModel> updateProfile({
    required String name,
    required String phone,
    String? avatarPath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'phone': phone,
        if (avatarPath != null)
          'avatar': await MultipartFile.fromFile(avatarPath, filename: 'avatar.jpg'),
      });
      final response = await _dio.post(ApiEndpoints.teacherUpdateProfile, data: formData);
      final data = response.data is Map && response.data['data'] != null
          ? response.data['data'] as Map<String, dynamic>
          : response.data as Map<String, dynamic>;
      return TeacherProfileModel.fromJson(data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) throw const NetworkException();
      throw ServerException(e.message ?? 'خطأ في الخادم');
    }
  }
}
