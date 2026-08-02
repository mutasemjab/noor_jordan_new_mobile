import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/fullscreen_image_viewer.dart';
import '../../domain/entities/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;
  final bool isRead;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: message.type == ChatMessageType.image
            ? const EdgeInsets.all(4)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMine ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
          border: isMine ? null : Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildContent(context),
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('h:mm a', 'ar').format(message.createdAt),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    color: isMine ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
                if (isMine) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all_rounded,
                    size: 14,
                    color: isRead ? const Color(0xFF4FC3F7) : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (message.type) {
      case ChatMessageType.text:
        return Text(
          message.text ?? '',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            height: 1.5,
            color: isMine ? Colors.white : AppColors.textPrimary,
          ),
        );
      case ChatMessageType.image:
        return GestureDetector(
          onTap: () => FullscreenImageViewer.open(context, message.mediaUrl ?? ''),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: message.mediaUrl ?? '',
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: 200,
                height: 200,
                color: AppColors.divider,
                child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              ),
              errorWidget: (_, __, ___) => Container(
                width: 200,
                height: 200,
                color: AppColors.divider,
                child: const Icon(Icons.broken_image_outlined, color: AppColors.textSecondary),
              ),
            ),
          ),
        );
      case ChatMessageType.voice:
        return _VoiceMessagePlayer(
          url: message.mediaUrl ?? '',
          durationSeconds: message.mediaDurationSeconds ?? 0,
          isMine: isMine,
        );
    }
  }
}

class _VoiceMessagePlayer extends StatefulWidget {
  final String url;
  final int durationSeconds;
  final bool isMine;

  const _VoiceMessagePlayer({
    required this.url,
    required this.durationSeconds,
    required this.isMine,
  });

  @override
  State<_VoiceMessagePlayer> createState() => _VoiceMessagePlayerState();
}

class _VoiceMessagePlayerState extends State<_VoiceMessagePlayer> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration? _total;

  @override
  void initState() {
    super.initState();
    _total = Duration(seconds: widget.durationSeconds);
    _player.onPlayerStateChanged.listen((s) {
      if (!mounted) return;
      setState(() => _isPlaying = s == PlayerState.playing);
    });
    _player.onPositionChanged.listen((p) {
      if (!mounted) return;
      setState(() => _position = p);
    });
    _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
    });
  }

  Future<void> _toggle() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play(UrlSource(widget.url));
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.toString().padLeft(1, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isMine ? Colors.white : AppColors.primary;
    final total = _total ?? Duration.zero;
    final progress = total.inMilliseconds == 0 ? 0.0 : _position.inMilliseconds / total.inMilliseconds;

    return SizedBox(
      width: 180,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _toggle,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: widget.isMine ? Colors.white.withOpacity(0.2) : AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: color, size: 20),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0, 1),
                    minHeight: 3,
                    backgroundColor: widget.isMine ? Colors.white24 : AppColors.divider,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _fmt(_isPlaying || _position > Duration.zero ? _position : total),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    color: widget.isMine ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
