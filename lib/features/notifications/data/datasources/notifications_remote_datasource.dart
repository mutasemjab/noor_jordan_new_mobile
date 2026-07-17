import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<NotificationsDataModel> getNotifications();
  Future<void> markRead(int id);
  Future<void> markAllRead();
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  final Dio _dio;

  NotificationsRemoteDataSourceImpl(this._dio);

  @override
  Future<NotificationsDataModel> getNotifications() async {
    try {
      final response = await _dio.get(ApiEndpoints.studentNotifications);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return NotificationsDataModel.fromJson(data);
      }
      return const NotificationsDataModel(unreadCount: 0, notifications: []);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }
      throw ServerException(
        e.response?.data?['message'] as String? ?? 'حدث خطأ في السيرفر',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> markRead(int id) async {
    try {
      await _dio.post(ApiEndpoints.studentMarkNotificationRead(id));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }
      throw ServerException(
        e.response?.data?['message'] as String? ?? 'حدث خطأ في السيرفر',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> markAllRead() async {
    try {
      await _dio.post(ApiEndpoints.studentMarkAllRead);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }
      throw ServerException(
        e.response?.data?['message'] as String? ?? 'حدث خطأ في السيرفر',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
