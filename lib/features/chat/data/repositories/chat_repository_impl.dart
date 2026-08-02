import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/local_storage.dart';
import '../../domain/entities/chat_contact.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_uid.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_firestore_datasource.dart';
import '../datasources/chat_remote_datasource.dart';
import '../services/firebase_chat_auth_bridge.dart';

typedef _Identity = ({bool isTeacher, int myId, String myUid, Map<String, dynamic> myInfo});

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;
  final ChatFirestoreDataSource _firestoreDataSource;
  final FirebaseChatAuthBridge _authBridge;
  final LocalStorage _localStorage;

  ChatRepositoryImpl(
    this._remoteDataSource,
    this._firestoreDataSource,
    this._authBridge,
    this._localStorage,
  );

  _Identity _identity() {
    final isTeacher = _localStorage.getUserType() == AppConstants.userTypeTeacher;
    final userData = _localStorage.getUserData() ?? {};
    final myId = (userData['id'] as num?)?.toInt() ?? 0;
    final myUid = isTeacher ? ChatUid.teacher(myId) : ChatUid.student(myId);
    final myInfo = {
      'name': userData['name'] as String? ?? '',
      'avatar': userData['avatar'] as String?,
      'role': isTeacher ? 'teacher' : 'student',
    };
    return (isTeacher: isTeacher, myId: myId, myUid: myUid, myInfo: myInfo);
  }

  @override
  Future<Either<Failure, String>> ensureReady() async {
    try {
      final ids = _identity();
      final uid = await _authBridge.ensureSignedIn(
        isTeacher: ids.isTeacher,
        expectedUid: ids.myUid,
      );
      return Right(uid);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on FirebaseAuthException catch (e) {
      debugPrint('[Chat] FirebaseAuthException in ensureReady: ${e.code} — ${e.message}');
      return Left(ServerFailure('تعذّر تفعيل المحادثة (${e.code})'));
    } catch (e, st) {
      debugPrint('[Chat] Unexpected error in ensureReady: $e\n$st');
      return Left(ServerFailure('تعذّر تفعيل المحادثة: $e'));
    }
  }

  @override
  String conversationIdFor(ChatContact contact) {
    final ids = _identity();
    return ChatUid.conversationId(
      teacherId: ids.isTeacher ? ids.myId : contact.id,
      studentId: ids.isTeacher ? contact.id : ids.myId,
    );
  }

  @override
  Stream<List<Conversation>> watchConversations() {
    return _firestoreDataSource.watchConversations(_identity().myUid);
  }

  @override
  Stream<List<ChatMessage>> watchMessages(String conversationId) {
    return _firestoreDataSource.watchMessages(conversationId);
  }

  Future<void> _ensureConversationWith(ChatContact contact, _Identity ids, String conversationId) {
    return _firestoreDataSource.ensureConversation(
      conversationId: conversationId,
      myUid: ids.myUid,
      myInfo: ids.myInfo,
      otherUid: contact.uid,
      otherInfo: {
        'name': contact.name,
        'avatar': contact.avatar,
        'role': ids.isTeacher ? 'student' : 'teacher',
      },
    );
  }

  @override
  Future<Either<Failure, void>> sendTextMessage({
    required ChatContact contact,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return const Right(null);
    try {
      final ids = _identity();
      final conversationId = conversationIdFor(contact);
      await _ensureConversationWith(contact, ids, conversationId);
      await _firestoreDataSource.sendMessage(
        conversationId: conversationId,
        senderId: ids.myUid,
        recipientUid: contact.uid,
        type: ChatMessageType.text,
        text: trimmed,
      );
      unawaited(_remoteDataSource.notify(
        recipientType: ids.isTeacher ? 'student' : 'teacher',
        recipientId: contact.id,
        senderName: ids.myInfo['name'] as String? ?? '',
        messageType: ChatMessageType.text,
        messagePreview: trimmed,
      ));
      return const Right(null);
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e, st) {
      debugPrint('[Chat] Unexpected error in sendTextMessage: $e\n$st');
      return Left(ServerFailure('تعذّر إرسال الرسالة: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendMediaMessage({
    required ChatContact contact,
    required File file,
    required ChatMessageType type,
    int? durationSeconds,
  }) async {
    try {
      final ids = _identity();
      final uploaded = await _remoteDataSource.uploadMedia(
        file: file,
        type: type,
        durationSeconds: durationSeconds,
      );
      final conversationId = conversationIdFor(contact);
      await _ensureConversationWith(contact, ids, conversationId);
      await _firestoreDataSource.sendMessage(
        conversationId: conversationId,
        senderId: ids.myUid,
        recipientUid: contact.uid,
        type: type,
        mediaUrl: uploaded.url,
        mediaDurationSeconds: uploaded.durationSeconds ?? durationSeconds,
      );
      unawaited(_remoteDataSource.notify(
        recipientType: ids.isTeacher ? 'student' : 'teacher',
        recipientId: contact.id,
        senderName: ids.myInfo['name'] as String? ?? '',
        messageType: type,
      ));
      return const Right(null);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e, st) {
      debugPrint('[Chat] Unexpected error in sendMediaMessage: $e\n$st');
      return Left(ServerFailure('تعذّر إرسال الملف: $e'));
    }
  }

  @override
  Future<void> markConversationRead(String conversationId) {
    return _firestoreDataSource.markConversationRead(conversationId, _identity().myUid);
  }

  @override
  Future<Either<Failure, List<ChatContact>>> getMyTeachers() async {
    try {
      final teachers = await _remoteDataSource.getMyTeachers();
      return Right(teachers);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e, st) {
      debugPrint('[Chat] Unexpected error in getMyTeachers: $e\n$st');
      return Left(ServerFailure('تعذّر تحميل قائمة المعلمين: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> broadcastToClass({
    required int classId,
    String? text,
    File? mediaFile,
    ChatMessageType? mediaType,
    int? durationSeconds,
  }) async {
    try {
      int? mediaId;
      if (mediaFile != null && mediaType != null) {
        final uploaded = await _remoteDataSource.uploadMedia(
          file: mediaFile,
          type: mediaType,
          durationSeconds: durationSeconds,
        );
        mediaId = uploaded.id;
      }
      final count = await _remoteDataSource.broadcastToClass(
        classId: classId,
        text: text,
        mediaId: mediaId,
      );
      return Right(count);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e, st) {
      debugPrint('[Chat] Unexpected error in broadcastToClass: $e\n$st');
      return Left(ServerFailure('تعذّر إرسال البث الجماعي: $e'));
    }
  }
}
