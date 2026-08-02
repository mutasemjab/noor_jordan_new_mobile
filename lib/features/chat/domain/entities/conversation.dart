import 'package:equatable/equatable.dart';
import 'chat_message.dart';

class Conversation extends Equatable {
  final String id;
  final String otherUid;
  final String otherName;
  final String? otherAvatar;
  final String? lastMessageText;
  final ChatMessageType? lastMessageType;
  final String? lastMessageSenderId;
  final DateTime? lastMessageAt;
  final int unreadCount;

  const Conversation({
    required this.id,
    required this.otherUid,
    required this.otherName,
    this.otherAvatar,
    this.lastMessageText,
    this.lastMessageType,
    this.lastMessageSenderId,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  @override
  List<Object?> get props => [
        id,
        otherUid,
        otherName,
        otherAvatar,
        lastMessageText,
        lastMessageType,
        lastMessageSenderId,
        lastMessageAt,
        unreadCount,
      ];
}
