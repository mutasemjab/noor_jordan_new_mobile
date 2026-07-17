import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<StudentProfileModel> getProfile();
  Future<StudentProfileModel> updateProfile({required String name, required String phone, String? avatarPath});
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio _dio;
  ProfileRemoteDataSourceImpl(this._dio);

  @override
  Future<StudentProfileModel> getProfile() async {
    try {
      final response = await _dio.get(ApiEndpoints.studentProfile);
      return StudentProfileModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) throw const NetworkException();
      throw ServerException(e.message ?? 'خطأ في الخادم');
    }
  }

  @override
  Future<StudentProfileModel> updateProfile({required String name, required String phone, String? avatarPath}) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'phone': phone,
        '_method': 'PUT',
        if (avatarPath != null)
          'avatar': await MultipartFile.fromFile(avatarPath, filename: 'avatar.jpg'),
      });
      final response = await _dio.post(ApiEndpoints.studentProfile, data: formData);
      return StudentProfileModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) throw const NetworkException();
      throw ServerException(e.message ?? 'خطأ في الخادم');
    }
  }
}
