import 'dart:io';

import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/chat_message.dart';
import '../models/chat_contact_model.dart';
import '../models/chat_media_upload_result.dart';

abstract class ChatRemoteDataSource {
  Future<String> getFirebaseToken({required bool isTeacher});

  Future<List<ChatContactModel>> getMyTeachers();

  Future<ChatMediaUploadResult> uploadMedia({
    required File file,
    required ChatMessageType type,
    int? durationSeconds,
  });

  Future<void> notify({
    required String recipientType,
    required int recipientId,
    required String senderName,
    required ChatMessageType messageType,
    String? messagePreview,
  });

  Future<int> broadcastToClass({
    required int classId,
    String? text,
    int? mediaId,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final Dio _dio;

  ChatRemoteDataSourceImpl(this._dio);

  @override
  Future<String> getFirebaseToken({required bool isTeacher}) async {
    try {
      final response = await _dio.get(
        isTeacher ? ApiEndpoints.teacherFirebaseToken : ApiEndpoints.studentFirebaseToken,
      );
      final data = response.data;
      final payload = data is Map<String, dynamic> ? data['data'] as Map<String, dynamic>? : null;
      final token = payload?['firebase_token'] as String?;
      if (token == null || token.isEmpty) {
        throw ServerException('تعذّر تفعيل المحادثة، حاول مرة أخرى');
      }
      return token;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<List<ChatContactModel>> getMyTeachers() async {
    try {
      final response = await _dio.get(ApiEndpoints.studentTeachers);
      final data = response.data;
      final list = data is Map<String, dynamic> ? data['data'] as List<dynamic>? ?? [] : <dynamic>[];
      return list
          .whereType<Map<String, dynamic>>()
          .map((e) => ChatContactModel.teacher(e))
          .toList();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<ChatMediaUploadResult> uploadMedia({
    required File file,
    required ChatMessageType type,
    int? durationSeconds,
  }) async {
    try {
      final typeStr = type == ChatMessageType.voice ? 'voice' : 'image';
      final formData = FormData.fromMap({
        'type': typeStr,
        if (durationSeconds != null) 'duration_seconds': durationSeconds,
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split(Platform.pathSeparator).last,
          contentType: type == ChatMessageType.voice ? DioMediaType('audio', 'mp4') : null,
        ),
      });
      final response = await _dio.post(ApiEndpoints.chatMedia, data: formData);
      final data = response.data;
      final payload = data is Map<String, dynamic> ? data['data'] as Map<String, dynamic>? : null;
      if (payload == null) {
        throw ServerException('تعذّر رفع الملف');
      }
      return ChatMediaUploadResult.fromJson(payload);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<void> notify({
    required String recipientType,
    required int recipientId,
    required String senderName,
    required ChatMessageType messageType,
    String? messagePreview,
  }) async {
    try {
      await _dio.post(ApiEndpoints.chatNotify, data: {
        'recipient_type': recipientType,
        'recipient_id': recipientId,
        'sender_name': senderName,
        'message_type': messageType.name,
        if (messagePreview != null) 'message_preview': messagePreview,
      });
    } on DioException {
      // Best-effort — a failed push notification shouldn't block the chat itself.
    }
  }

  @override
  Future<int> broadcastToClass({
    required int classId,
    String? text,
    int? mediaId,
  }) async {
    try {
      final response = await _dio.post(ApiEndpoints.teacherChatBroadcast, data: {
        'class_id': classId,
        if (text != null) 'text': text,
        if (mediaId != null) 'media_id': mediaId,
      });
      final data = response.data;
      final payload = data is Map<String, dynamic> ? data['data'] as Map<String, dynamic>? : null;
      return (payload?['sent_to'] as num?)?.toInt() ?? 0;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Exception _mapDioException(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const NetworkException();
    }
    final statusCode = e.response?.statusCode;
    if (statusCode == 401) return const UnauthorizedException();
    return ServerException(
      e.response?.data?['message'] as String? ?? 'حدث خطأ في السيرفر',
      statusCode: statusCode,
    );
  }
}
