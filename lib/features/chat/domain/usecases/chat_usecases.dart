import 'dart:io';

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat_contact.dart';
import '../entities/chat_message.dart';
import '../entities/conversation.dart';
import '../repositories/chat_repository.dart';

class EnsureChatReadyUseCase {
  final ChatRepository _repository;
  EnsureChatReadyUseCase(this._repository);
  Future<Either<Failure, String>> call() => _repository.ensureReady();
}

class GetConversationIdUseCase {
  final ChatRepository _repository;
  GetConversationIdUseCase(this._repository);
  String call(ChatContact contact) => _repository.conversationIdFor(contact);
}

class WatchConversationsUseCase {
  final ChatRepository _repository;
  WatchConversationsUseCase(this._repository);
  Stream<List<Conversation>> call() => _repository.watchConversations();
}

class WatchMessagesUseCase {
  final ChatRepository _repository;
  WatchMessagesUseCase(this._repository);
  Stream<List<ChatMessage>> call(String conversationId) =>
      _repository.watchMessages(conversationId);
}

class SendTextMessageUseCase {
  final ChatRepository _repository;
  SendTextMessageUseCase(this._repository);
  Future<Either<Failure, void>> call({
    required ChatContact contact,
    required String text,
  }) =>
      _repository.sendTextMessage(contact: contact, text: text);
}

class SendMediaMessageUseCase {
  final ChatRepository _repository;
  SendMediaMessageUseCase(this._repository);
  Future<Either<Failure, void>> call({
    required ChatContact contact,
    required File file,
    required ChatMessageType type,
    int? durationSeconds,
  }) =>
      _repository.sendMediaMessage(
        contact: contact,
        file: file,
        type: type,
        durationSeconds: durationSeconds,
      );
}

class MarkConversationReadUseCase {
  final ChatRepository _repository;
  MarkConversationReadUseCase(this._repository);
  Future<void> call(String conversationId) =>
      _repository.markConversationRead(conversationId);
}

class GetMyTeachersUseCase {
  final ChatRepository _repository;
  GetMyTeachersUseCase(this._repository);
  Future<Either<Failure, List<ChatContact>>> call() => _repository.getMyTeachers();
}

class BroadcastToClassUseCase {
  final ChatRepository _repository;
  BroadcastToClassUseCase(this._repository);
  Future<Either<Failure, int>> call({
    required int classId,
    String? text,
    File? mediaFile,
    ChatMessageType? mediaType,
    int? durationSeconds,
  }) =>
      _repository.broadcastToClass(
        classId: classId,
        text: text,
        mediaFile: mediaFile,
        mediaType: mediaType,
        durationSeconds: durationSeconds,
      );
}
