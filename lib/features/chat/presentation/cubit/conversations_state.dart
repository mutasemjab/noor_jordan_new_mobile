import 'package:equatable/equatable.dart';
import '../../domain/entities/conversation.dart';

abstract class ConversationsState extends Equatable {
  const ConversationsState();

  @override
  List<Object?> get props => [];
}

class ConversationsInitial extends ConversationsState {
  const ConversationsInitial();
}

class ConversationsLoading extends ConversationsState {
  const ConversationsLoading();
}

class ConversationsLoaded extends ConversationsState {
  final List<Conversation> items;

  const ConversationsLoaded(this.items);

  int get totalUnread => items.fold(0, (sum, c) => sum + c.unreadCount);

  @override
  List<Object?> get props => [items];
}

class ConversationsError extends ConversationsState {
  final String message;

  const ConversationsError(this.message);

  @override
  List<Object?> get props => [message];
}
