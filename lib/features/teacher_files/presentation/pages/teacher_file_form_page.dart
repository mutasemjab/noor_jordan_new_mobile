import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../teacher_common/domain/entities/teacher_subject.dart';
import '../../domain/entities/teacher_file_item.dart';
import '../cubit/teacher_files_cubit.dart';

class TeacherFileFormPage extends StatefulWidget {
  final TeacherFileKind kind;
  final TeacherSubject subject;
  final TeacherFileItem? existingFile;

  const TeacherFileFormPage({super.key, required this.kind, required this.subject, this.existingFile});

  @override
  State<TeacherFileFormPage> createState() => _TeacherFileFormPageState();
}

class _TeacherFileFormPageState extends State<TeacherFileFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _yearCtrl;
  File? _pickedFile;
  String? _pickedFileName;
  bool _saving = false;

  bool get _isEdit => widget.existingFile != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.existingFile?.title ?? '');
    _yearCtrl = TextEditingController(text: widget.existingFile?.year?.toString() ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result == null || result.files.single.path == null) return;
    setState(() {
      _pickedFile = File(result.files.single.path!);
      _pickedFileName = result.files.single.name;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isEdit && _pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر ملف PDF أولاً', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.error),
      );
      return;
    }
    final year = _yearCtrl.text.trim().isEmpty ? null : int.tryParse(_yearCtrl.text.trim());
    setState(() => _saving = true);
    final cubit = context.read<TeacherFilesCubit>();
    final error = _isEdit
        ? await cubit.update(id: widget.existingFile!.id, title: _titleCtrl.text.trim(), year: year, file: _pickedFile)
        : await cubit.create(title: _titleCtrl.text.trim(), year: year, file: _pickedFile!);
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.error));
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final kind = widget.kind;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEdit ? 'تعديل ${kind.label}' : 'إضافة ${kind.label}', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 15)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleCtrl,
              style: const TextStyle(fontFamily: 'Cairo'),
              decoration: InputDecoration(
                labelText: 'العنوان',
                labelStyle: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'الرجاء إدخال العنوان' : null,
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(12)),
              child: Text('المادة: ${widget.subject.name}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary)),
            ),
            if (kind.supportsYear) ...[
              const SizedBox(height: 14),
              TextFormField(
                controller: _yearCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontFamily: 'Cairo'),
                decoration: InputDecoration(
                  labelText: kind.yearRequired ? 'السنة (مطلوب)' : 'السنة (اختياري)',
                  labelStyle: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                ),
                validator: (v) {
                  if (kind.yearRequired && (v == null || v.trim().isEmpty)) return 'الرجاء إدخال السنة';
                  if (v != null && v.trim().isNotEmpty && int.tryParse(v.trim()) == null) return 'رقم غير صحيح';
                  return null;
                },
              ),
            ],
            const SizedBox(height: 14),
            InkWell(
              onTap: _pickFile,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf_rounded, color: AppColors.error, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _pickedFileName ?? (_isEdit ? 'اختر ملف جديد (اختياري)' : 'اختر ملف PDF'),
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.attach_file_rounded, color: AppColors.primary, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _saving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(_isEdit ? 'حفظ التعديلات' : 'رفع الملف', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
