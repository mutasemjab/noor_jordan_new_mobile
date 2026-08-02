import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/chat_contact.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/conversation.dart';
import '../cubit/conversations_cubit.dart';
import '../cubit/conversations_state.dart';
import 'chat_page.dart';

class ConversationsListPage extends StatelessWidget {
  final bool isTeacher;
  final VoidCallback? onStartNewChat;

  const ConversationsListPage({
    super.key,
    this.isTeacher = false,
    this.onStartNewChat,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ConversationsCubit>()..load(),
      child: _ConversationsView(isTeacher: isTeacher, onStartNewChat: onStartNewChat),
    );
  }
}

class _ConversationsView extends StatelessWidget {
  final bool isTeacher;
  final VoidCallback? onStartNewChat;
  const _ConversationsView({required this.isTeacher, this.onStartNewChat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'الرسائل',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          if (onStartNewChat != null)
            IconButton(
              icon: const Icon(Icons.edit_note_rounded),
              onPressed: onStartNewChat,
            ),
        ],
      ),
      floatingActionButton: onStartNewChat == null
          ? null
          : FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: onStartNewChat,
              child: const Icon(Icons.chat_rounded, color: Colors.white),
            ),
      body: BlocBuilder<ConversationsCubit, ConversationsState>(
        builder: (context, state) {
          if (state is ConversationsLoading || state is ConversationsInitial) {
            return const ShimmerList(itemCount: 6, itemHeight: 72);
          }
          if (state is ConversationsError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context.read<ConversationsCubit>().load(),
            );
          }
          if (state is ConversationsLoaded) {
            if (state.items.isEmpty) {
              return EmptyStateWidget(
                message: 'لا توجد محادثات بعد',
                subMessage: isTeacher ? 'ابدأ محادثة مع أحد طلابك' : 'ابدأ محادثة مع أحد معلميك',
                icon: Icons.forum_outlined,
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.items.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 78, color: AppColors.divider),
              itemBuilder: (_, i) => _ConversationTile(conversation: state.items[i]),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  const _ConversationTile({required this.conversation});

  String _preview() {
    switch (conversation.lastMessageType) {
      case ChatMessageType.image:
        return '📷 صورة';
      case ChatMessageType.voice:
        return '🎤 رسالة صوتية';
      case ChatMessageType.text:
      case null:
        return conversation.lastMessageText ?? '';
    }
  }

  String _time() {
    final at = conversation.lastMessageAt;
    if (at == null) return '';
    final now = DateTime.now();
    if (at.year == now.year && at.month == now.month && at.day == now.day) {
      return DateFormat('h:mm a', 'ar').format(at);
    }
    return DateFormat('d/M', 'ar').format(at);
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = conversation.unreadCount > 0;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: AppColors.primary.withOpacity(0.1),
        backgroundImage: conversation.otherAvatar != null && conversation.otherAvatar!.isNotEmpty
            ? CachedNetworkImageProvider(conversation.otherAvatar!)
            : null,
        child: conversation.otherAvatar == null || conversation.otherAvatar!.isEmpty
            ? Text(
                conversation.otherName.isNotEmpty ? conversation.otherName[0] : '؟',
                style: const TextStyle(fontFamily: 'Cairo', color: AppColors.primary, fontWeight: FontWeight.w700),
              )
            : null,
      ),
      title: Text(
        conversation.otherName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      ),
      subtitle: Text(
        _preview(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13,
          color: hasUnread ? AppColors.textPrimary : AppColors.textSecondary,
          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _time(),
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              color: hasUnread ? AppColors.primary : AppColors.textSecondary,
              fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),
          if (hasUnread)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(12)),
              child: Text(
                conversation.unreadCount > 99 ? '99+' : '${conversation.unreadCount}',
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
        ],
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatPage(
              contact: ChatContact(
                id: int.tryParse(conversation.otherUid.split('_').last) ?? 0,
                uid: conversation.otherUid,
                name: conversation.otherName,
                avatar: conversation.otherAvatar,
              ),
            ),
          ),
        );
      },
    );
  }
}
