import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/chat_message.dart';
import '../cubit/broadcast_cubit.dart';
import '../cubit/broadcast_state.dart';
import '../widgets/attachment_sheet.dart';

class BroadcastComposePage extends StatelessWidget {
  final int classId;
  final String className;

  const BroadcastComposePage({super.key, required this.classId, required this.className});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BroadcastCubit>(),
      child: _BroadcastComposeView(classId: classId, className: className),
    );
  }
}

class _BroadcastComposeView extends StatefulWidget {
  final int classId;
  final String className;
  const _BroadcastComposeView({required this.classId, required this.className});

  @override
  State<_BroadcastComposeView> createState() => _BroadcastComposeViewState();
}

class _BroadcastComposeViewState extends State<_BroadcastComposeView> {
  final _controller = TextEditingController();
  File? _image;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await AttachmentSheet.pick(context);
    if (file != null) setState(() => _image = file);
  }

  void _send(BuildContext context) {
    final text = _controller.text.trim();
    if (text.isEmpty && _image == null) return;
    context.read<BroadcastCubit>().send(
          classId: widget.classId,
          text: text.isNotEmpty ? text : null,
          mediaFile: _image,
          mediaType: _image != null ? ChatMessageType.image : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'بث جماعي — ${widget.className}',
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      body: BlocConsumer<BroadcastCubit, BroadcastState>(
        listener: (context, state) {
          if (state is BroadcastSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'تم إرسال الرسالة إلى ${state.sentTo} طالب',
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                backgroundColor: AppColors.present,
              ),
            );
            Navigator.of(context).pop();
          }
          if (state is BroadcastError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message, style: const TextStyle(fontFamily: 'Cairo')),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isSending = state is BroadcastSending;
          return Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.campaign_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'هذه الرسالة ستصل لجميع طلاب صف ${widget.className}',
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_image != null)
                        Stack(
                          alignment: Alignment.topLeft,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(_image!, height: 180, width: double.infinity, fit: BoxFit.cover),
                            ),
                            IconButton(
                              icon: const CircleAvatar(
                                backgroundColor: Colors.black45,
                                child: Icon(Icons.close_rounded, color: Colors.white, size: 18),
                              ),
                              onPressed: () => setState(() => _image = null),
                            ),
                          ],
                        ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _controller,
                        maxLines: 6,
                        minLines: 4,
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'اكتب نص الرسالة الجماعية...',
                          hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary),
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.divider),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.divider),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image_outlined),
                        label: const Text('إرفاق صورة', style: TextStyle(fontFamily: 'Cairo')),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + MediaQuery.of(context).padding.bottom),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isSending ? null : () => _send(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isSending
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('إرسال للصف بالكامل', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
