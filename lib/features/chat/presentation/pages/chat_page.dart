import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../domain/entities/chat_contact.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/message_bubble.dart';

class ChatPage extends StatelessWidget {
  final ChatContact contact;
  const ChatPage({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ChatCubit>(param1: contact)..init(),
      child: _ChatView(contact: contact),
    );
  }
}

class _ChatView extends StatelessWidget {
  final ChatContact contact;
  const _ChatView({required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              backgroundImage: contact.avatar != null && contact.avatar!.isNotEmpty
                  ? CachedNetworkImageProvider(contact.avatar!)
                  : null,
              child: contact.avatar == null || contact.avatar!.isEmpty
                  ? Text(
                      contact.name.isNotEmpty ? contact.name[0] : '؟',
                      style: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.w700),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    contact.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  if (contact.subtitle != null)
                    Text(
                      contact.subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white70),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          if (state is ChatError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context.read<ChatCubit>().init(),
            );
          }
          if (state is ChatReady) {
            return Column(
              children: [
                Expanded(
                  child: state.messages.isEmpty
                      ? const _EmptyChat()
                      : ListView.builder(
                          reverse: true,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          itemCount: state.messages.length,
                          itemBuilder: (_, i) {
                            final message = state.messages[i];
                            final isMine = message.isMine(state.myUid);
                            return MessageBubble(
                              message: message,
                              isMine: isMine,
                              isRead: isMine && message.readBy.length > 1,
                            );
                          },
                        ),
                ),
                ChatInputBar(
                  onSendText: (text) => context.read<ChatCubit>().sendText(text),
                  onSendImage: (file) => context.read<ChatCubit>().sendImage(file),
                  onSendVoice: (file, duration) => context.read<ChatCubit>().sendVoice(file, duration),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        },
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline_rounded, size: 56, color: AppColors.primary.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text(
              'ابدأ المحادثة الآن',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
