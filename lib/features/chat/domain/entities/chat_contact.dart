import 'package:equatable/equatable.dart';

/// A person the current user is allowed to start a chat with
/// (a teacher, for a student; a student, for a teacher).
class ChatContact extends Equatable {
  final int id;
  final String uid;
  final String name;
  final String? avatar;
  final String? subtitle;

  const ChatContact({
    required this.id,
    required this.uid,
    required this.name,
    this.avatar,
    this.subtitle,
  });

  @override
  List<Object?> get props => [id, uid, name, avatar, subtitle];
}
