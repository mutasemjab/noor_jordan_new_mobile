import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/conversation.dart';

class ConversationModel extends Conversation {
  const ConversationModel({
    required super.id,
    required super.otherUid,
    required super.otherName,
    super.otherAvatar,
    super.lastMessageText,
    super.lastMessageType,
    super.lastMessageSenderId,
    super.lastMessageAt,
    super.unreadCount,
  });

  factory ConversationModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String myUid,
  ) {
    final data = doc.data() ?? {};
    final participantIds = List<String>.from(data['participantIds'] as List? ?? []);
    final otherUid = participantIds.firstWhere((id) => id != myUid, orElse: () => '');
    final participants = data['participants'] as Map<String, dynamic>? ?? {};
    final otherInfo = participants[otherUid] as Map<String, dynamic>? ?? {};

    final lastMessage = data['lastMessage'] as Map<String, dynamic>?;
    final unreadCountMap = data['unreadCount'] as Map<String, dynamic>? ?? {};
    final lastMessageAtRaw = data['updatedAt'];

    return ConversationModel(
      id: doc.id,
      otherUid: otherUid,
      otherName: otherInfo['name'] as String? ?? '',
      otherAvatar: otherInfo['avatar'] as String?,
      lastMessageText: lastMessage?['text'] as String?,
      lastMessageType: _typeFrom(lastMessage?['type'] as String?),
      lastMessageSenderId: lastMessage?['senderId'] as String?,
      lastMessageAt: lastMessageAtRaw is Timestamp ? lastMessageAtRaw.toDate() : null,
      unreadCount: (unreadCountMap[myUid] as num?)?.toInt() ?? 0,
    );
  }

  static ChatMessageType? _typeFrom(String? raw) {
    switch (raw) {
      case 'image':
        return ChatMessageType.image;
      case 'voice':
        return ChatMessageType.voice;
      case 'text':
        return ChatMessageType.text;
      default:
        return null;
    }
  }
}
