import '../../domain/entities/chat_contact.dart';
import '../../domain/entities/chat_uid.dart';

class ChatContactModel extends ChatContact {
  const ChatContactModel({
    required super.id,
    required super.uid,
    required super.name,
    super.avatar,
    super.subtitle,
  });

  factory ChatContactModel.teacher(Map<String, dynamic> json) {
    final id = (json['id'] as num?)?.toInt() ?? 0;
    return ChatContactModel(
      id: id,
      uid: ChatUid.teacher(id),
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String?,
      subtitle: json['subject_name'] as String?,
    );
  }

  factory ChatContactModel.student(Map<String, dynamic> json) {
    final id = (json['id'] as num?)?.toInt() ?? 0;
    return ChatContactModel(
      id: id,
      uid: ChatUid.student(id),
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String?,
      subtitle: json['class_name'] as String?,
    );
  }
}
