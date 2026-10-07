import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../teacher_common/domain/entities/teacher_subject.dart';
import '../../../teacher_common/presentation/widgets/subject_picker_field.dart';
import '../../domain/entities/teacher_external_link.dart';
import '../cubit/teacher_external_links_cubit.dart';

class TeacherExternalLinkFormPage extends StatefulWidget {
  final int classId;
  final TeacherExternalLink? existingLink;
  const TeacherExternalLinkFormPage({super.key, required this.classId, this.existingLink});

  @override
  State<TeacherExternalLinkFormPage> createState() => _TeacherExternalLinkFormPageState();
}

class _TeacherExternalLinkFormPageState extends State<TeacherExternalLinkFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _urlCtrl;
  TeacherSubject? _subject;
  bool _saving = false;

  bool get _isEditing => widget.existingLink != null;

  @override
  void initState() {
    super.initState();
    final link = widget.existingLink;
    _urlCtrl = TextEditingController(text: link?.url ?? '');
    if (link?.subject != null) _subject = link!.subject;
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isEditing && _subject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر المادة أولاً', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.error),
      );
      return;
    }
    setState(() => _saving = true);
    final cubit = context.read<TeacherExternalLinksCubit>();
    final error = _isEditing
        ? await cubit.update(id: widget.existingLink!.id, url: _urlCtrl.text.trim())
        : await cubit.create(subjectId: _subject!.id, url: _urlCtrl.text.trim());
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.error),
      );
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'تعديل الرابط' : 'إضافة رابط', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 15)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_isEditing)
              // Subject/class can't be changed after creation — show read-only.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.divider.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.menu_book_outlined, color: AppColors.textSecondary, size: 18),
                    const SizedBox(width: 10),
                    Text(_subject?.name ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textSecondary)),
                  ],
                ),
              )
            else
              SubjectPickerField(
                classId: widget.classId,
                selectedSubjectId: _subject?.id,
                onChanged: (s) => setState(() => _subject = s),
              ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _urlCtrl,
              style: const TextStyle(fontFamily: 'Cairo'),
              keyboardType: TextInputType.url,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                labelText: 'الرابط',
                hintText: 'https://...',
                hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
                labelStyle: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'الرجاء إدخال الرابط';
                final uri = Uri.tryParse(v.trim());
                if (uri == null || !uri.isAbsolute) return 'رابط غير صحيح';
                return null;
              },
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
                    : Text(_isEditing ? 'حفظ التعديلات' : 'إضافة الرابط', style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
