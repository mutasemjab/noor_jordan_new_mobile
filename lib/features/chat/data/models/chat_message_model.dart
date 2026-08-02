import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.senderId,
    required super.type,
    super.text,
    super.mediaUrl,
    super.mediaDurationSeconds,
    required super.createdAt,
    super.readBy,
    super.isBroadcast,
  });

  factory ChatMessageModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final createdAtRaw = data['createdAt'];
    return ChatMessageModel(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      type: _typeFrom(data['type'] as String?),
      text: data['text'] as String?,
      mediaUrl: data['mediaUrl'] as String?,
      mediaDurationSeconds: (data['mediaDurationSeconds'] as num?)?.toInt(),
      createdAt: createdAtRaw is Timestamp ? createdAtRaw.toDate() : DateTime.now(),
      readBy: List<String>.from(data['readBy'] as List? ?? []),
      isBroadcast: data['isBroadcast'] as bool? ?? false,
    );
  }

  static ChatMessageType _typeFrom(String? raw) {
    switch (raw) {
      case 'image':
        return ChatMessageType.image;
      case 'voice':
        return ChatMessageType.voice;
      default:
        return ChatMessageType.text;
    }
  }
}
