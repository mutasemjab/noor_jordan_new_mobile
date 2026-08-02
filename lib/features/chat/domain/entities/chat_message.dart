import 'package:equatable/equatable.dart';

enum ChatMessageType { text, image, voice }

class ChatMessage extends Equatable {
  final String id;
  final String senderId;
  final ChatMessageType type;
  final String? text;
  final String? mediaUrl;
  final int? mediaDurationSeconds;
  final DateTime createdAt;
  final List<String> readBy;
  final bool isBroadcast;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.type,
    this.text,
    this.mediaUrl,
    this.mediaDurationSeconds,
    required this.createdAt,
    this.readBy = const [],
    this.isBroadcast = false,
  });

  bool isMine(String myUid) => senderId == myUid;

  bool isReadBy(String uid) => readBy.contains(uid);

  @override
  List<Object?> get props => [
        id,
        senderId,
        type,
        text,
        mediaUrl,
        mediaDurationSeconds,
        createdAt,
        readBy,
        isBroadcast,
      ];
}
