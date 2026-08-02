import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatReady extends ChatState {
  final String myUid;
  final String conversationId;
  final List<ChatMessage> messages;
  final bool isSending;

  const ChatReady({
    required this.myUid,
    required this.conversationId,
    required this.messages,
    this.isSending = false,
  });

  ChatReady copyWith({List<ChatMessage>? messages, bool? isSending}) {
    return ChatReady(
      myUid: myUid,
      conversationId: conversationId,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
    );
  }

  @override
  List<Object?> get props => [myUid, conversationId, messages, isSending];
}
