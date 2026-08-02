import 'dart:io';

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat_contact.dart';
import '../entities/chat_message.dart';
import '../entities/conversation.dart';

abstract class ChatRepository {
  /// Signs into Firebase (custom token) and returns the current user's uid
  /// (e.g. "student_482"). Safe to call repeatedly.
  Future<Either<Failure, String>> ensureReady();

  String conversationIdFor(ChatContact contact);

  Stream<List<Conversation>> watchConversations();

  Stream<List<ChatMessage>> watchMessages(String conversationId);

  Future<Either<Failure, void>> sendTextMessage({
    required ChatContact contact,
    required String text,
  });

  Future<Either<Failure, void>> sendMediaMessage({
    required ChatContact contact,
    required File file,
    required ChatMessageType type,
    int? durationSeconds,
  });

  Future<void> markConversationRead(String conversationId);

  /// Student side: teachers who actually teach the student.
  Future<Either<Failure, List<ChatContact>>> getMyTeachers();

  /// Teacher side: broadcast a text and/or media message to every student
  /// in [classId]. Returns how many students it was sent to.
  Future<Either<Failure, int>> broadcastToClass({
    required int classId,
    String? text,
    File? mediaFile,
    ChatMessageType? mediaType,
    int? durationSeconds,
  });
}
