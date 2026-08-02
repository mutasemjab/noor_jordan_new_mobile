import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../../../../core/constants/app_colors.dart';
import 'attachment_sheet.dart';

class ChatInputBar extends StatefulWidget {
  final ValueChanged<String> onSendText;
  final ValueChanged<File> onSendImage;
  final void Function(File file, int durationSeconds) onSendVoice;

  const ChatInputBar({
    super.key,
    required this.onSendText,
    required this.onSendImage,
    required this.onSendVoice,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  final _recorder = AudioRecorder();
  bool _hasText = false;
  bool _isRecording = false;
  int _seconds = 0;
  Timer? _timer;
  String? _recordingPath;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _recorder.dispose();
    super.dispose();
  }

  void _submitText() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSendText(text);
    _controller.clear();
  }

  Future<void> _pickAttachment() async {
    final file = await AttachmentSheet.pick(context);
    if (file != null) widget.onSendImage(file);
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return;
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/chat_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
    setState(() {
      _isRecording = true;
      _seconds = 0;
      _recordingPath = path;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _seconds++);
    });
  }

  Future<void> _stopAndSend() async {
    _timer?.cancel();
    final path = await _recorder.stop();
    final duration = _seconds;
    setState(() => _isRecording = false);
    final resolvedPath = path ?? _recordingPath;
    if (resolvedPath != null && duration > 0) {
      widget.onSendVoice(File(resolvedPath), duration);
    }
  }

  Future<void> _cancelRecording() async {
    _timer?.cancel();
    await _recorder.stop();
    if (_recordingPath != null) {
      final f = File(_recordingPath!);
      if (await f.exists()) await f.delete();
    }
    setState(() => _isRecording = false);
  }

  String _fmt(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 8 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: _isRecording ? _buildRecordingRow() : _buildTextRow(),
      ),
    );
  }

  Widget _buildRecordingRow() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
          onPressed: _cancelRecording,
        ),
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
        ),
        Expanded(
          child: Text(
            _fmt(_seconds),
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textPrimary),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send_rounded, color: AppColors.primary),
          onPressed: _stopAndSend,
        ),
      ],
    );
  }

  Widget _buildTextRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary),
          onPressed: _pickAttachment,
        ),
        Expanded(
          child: Container(
            constraints: const BoxConstraints(maxHeight: 110),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(22),
            ),
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'اكتب رسالة...',
                hintStyle: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        _hasText
            ? IconButton(
                icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                onPressed: _submitText,
              )
            : IconButton(
                icon: const Icon(Icons.mic_none_rounded, color: AppColors.primary),
                onPressed: _startRecording,
              ),
      ],
    );
  }
}
