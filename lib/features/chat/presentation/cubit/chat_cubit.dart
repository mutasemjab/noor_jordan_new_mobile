import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_contact.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/chat_usecases.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final EnsureChatReadyUseCase _ensureReady;
  final GetConversationIdUseCase _getConversationId;
  final WatchMessagesUseCase _watchMessages;
  final SendTextMessageUseCase _sendText;
  final SendMediaMessageUseCase _sendMedia;
  final MarkConversationReadUseCase _markRead;

  final ChatContact contact;
  StreamSubscription? _subscription;

  ChatCubit({
    required this.contact,
    required EnsureChatReadyUseCase ensureReady,
    required GetConversationIdUseCase getConversationId,
    required WatchMessagesUseCase watchMessages,
    required SendTextMessageUseCase sendText,
    required SendMediaMessageUseCase sendMedia,
    required MarkConversationReadUseCase markRead,
  })  : _ensureReady = ensureReady,
        _getConversationId = getConversationId,
        _watchMessages = watchMessages,
        _sendText = sendText,
        _sendMedia = sendMedia,
        _markRead = markRead,
        super(const ChatInitial());

  Future<void> init() async {
    emit(const ChatLoading());
    final result = await _ensureReady();
    await result.fold(
      (failure) async => emit(ChatError(failure.message)),
      (myUid) async {
        final conversationId = _getConversationId(contact);
        emit(ChatReady(myUid: myUid, conversationId: conversationId, messages: const []));
        await _subscription?.cancel();
        _subscription = _watchMessages(conversationId).listen(
          _onMessages,
          onError: (_) => emit(const ChatError('تعذّر تحميل المحادثة')),
        );
      },
    );
  }

  void _onMessages(List<ChatMessage> messages) {
    final current = state;
    if (current is! ChatReady) return;
    emit(current.copyWith(messages: messages));

    final hasUnread = messages.any(
      (m) => m.senderId != current.myUid && !m.isReadBy(current.myUid),
    );
    if (hasUnread) {
      _markRead(current.conversationId);
    }
  }

  Future<void> sendText(String text) async {
    if (text.trim().isEmpty) return;
    final current = state;
    if (current is! ChatReady) return;
    emit(current.copyWith(isSending: true));
    await _sendText(contact: contact, text: text);
    final latest = state;
    if (latest is ChatReady) emit(latest.copyWith(isSending: false));
  }

  Future<void> sendImage(File file) async {
    final current = state;
    if (current is! ChatReady) return;
    emit(current.copyWith(isSending: true));
    await _sendMedia(contact: contact, file: file, type: ChatMessageType.image);
    final latest = state;
    if (latest is ChatReady) emit(latest.copyWith(isSending: false));
  }

  Future<void> sendVoice(File file, int durationSeconds) async {
    final current = state;
    if (current is! ChatReady) return;
    emit(current.copyWith(isSending: true));
    await _sendMedia(
      contact: contact,
      file: file,
      type: ChatMessageType.voice,
      durationSeconds: durationSeconds,
    );
    final latest = state;
    if (latest is ChatReady) emit(latest.copyWith(isSending: false));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
