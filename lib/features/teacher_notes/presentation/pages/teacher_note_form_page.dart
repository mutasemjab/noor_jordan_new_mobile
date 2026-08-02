import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../chat/presentation/widgets/attachment_sheet.dart';
import '../../../educational_notes/domain/entities/educational_note.dart';
import '../cubit/teacher_notes_cubit.dart';

class TeacherNoteFormPage extends StatefulWidget {
  final int classId;
  final EducationalNote? existingNote;

  const TeacherNoteFormPage({super.key, required this.classId, this.existingNote});

  @override
  State<TeacherNoteFormPage> createState() => _TeacherNoteFormPageState();
}

class _TeacherNoteFormPageState extends State<TeacherNoteFormPage> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late EducationalNoteType _type;
  late DateTime _date;
  File? _newAttachment;
  bool _saving = false;

  bool get _isEditing => widget.existingNote != null;

  @override
  void initState() {
    super.initState();
    final note = widget.existingNote;
    _titleCtrl = TextEditingController(text: note?.title ?? '');
    _descCtrl = TextEditingController(text: note?.description ?? '');
    _type = note?.type ?? EducationalNoteType.lesson;
    _date = note?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickAttachment() async {
    final file = await AttachmentSheet.pick(context);
    if (file != null) setState(() => _newAttachment = file);
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال عنوان', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.error),
      );
      return;
    }
    setState(() => _saving = true);
    final cubit = context.read<TeacherNotesCubit>();
    final String? error;
    if (_isEditing) {
      error = await cubit.update(
        noteId: widget.existingNote!.id,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        type: _type,
        date: _date,
        attachment: _newAttachment,
      );
    } else {
      error = await cubit.create(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        type: _type,
        date: _date,
        attachment: _newAttachment,
      );
    }
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.error),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'تعديل الملاحظة' : 'ملاحظة جديدة',
            style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 16)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Type selector
          Row(
            children: [
              Expanded(
                child: _TypeChip(
                  label: 'درس',
                  icon: Icons.menu_book_rounded,
                  color: AppColors.excused,
                  selected: _type == EducationalNoteType.lesson,
                  onTap: () => setState(() => _type = EducationalNoteType.lesson),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TypeChip(
                  label: 'واجب',
                  icon: Icons.edit_note_rounded,
                  color: AppColors.late,
                  selected: _type == EducationalNoteType.homework,
                  onTap: () => setState(() => _type = EducationalNoteType.homework),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleCtrl,
            style: const TextStyle(fontFamily: 'Cairo'),
            decoration: _decoration('العنوان'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descCtrl,
            maxLines: 5,
            style: const TextStyle(fontFamily: 'Cairo'),
            decoration: _decoration('الوصف (اختياري)'),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 18),
                  const SizedBox(width: 10),
                  Text(DateFormat('d MMMM yyyy', 'ar').format(_date),
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textPrimary)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_newAttachment != null)
            Stack(
              alignment: Alignment.topLeft,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_newAttachment!, height: 160, width: double.infinity, fit: BoxFit.cover),
                ),
                IconButton(
                  icon: const CircleAvatar(backgroundColor: Colors.black45, child: Icon(Icons.close_rounded, color: Colors.white, size: 18)),
                  onPressed: () => setState(() => _newAttachment = null),
                ),
              ],
            )
          else if (_isEditing && widget.existingNote!.attachment != null && widget.existingNote!.attachment!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: widget.existingNote!.attachment!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _pickAttachment,
            icon: const Icon(Icons.image_outlined),
            label: Text(_newAttachment != null || (_isEditing && widget.existingNote!.attachment != null) ? 'تغيير الصورة' : 'إرفاق صورة',
                style: const TextStyle(fontFamily: 'Cairo')),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _saving
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(_isEditing ? 'حفظ التعديلات' : 'إضافة الملاحظة',
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({required this.label, required this.icon, required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.12) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? color : AppColors.divider, width: selected ? 1.5 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? color : AppColors.textSecondary),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: selected ? color : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
