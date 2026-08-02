import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../teacher_common/domain/entities/teacher_subject.dart';
import '../../../teacher_common/presentation/widgets/subject_picker_field.dart';
import '../../domain/entities/teacher_exam.dart';
import '../cubit/teacher_exam_detail_cubit.dart';
import '../cubit/teacher_exams_cubit.dart';
import 'teacher_exam_detail_page.dart';

/// Create-mode: pass [classId] (reads [TeacherExamsCubit] from context).
/// Edit-mode: pass [existingExam] (reads [TeacherExamDetailCubit] from context).
class TeacherExamFormPage extends StatefulWidget {
  final int? classId;
  final String className;
  final TeacherExam? existingExam;

  const TeacherExamFormPage({super.key, this.classId, required this.className, this.existingExam});

  @override
  State<TeacherExamFormPage> createState() => _TeacherExamFormPageState();
}

class _TeacherExamFormPageState extends State<TeacherExamFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _durationCtrl;
  late final TextEditingController _totalMarksCtrl;
  late final TextEditingController _passMarksCtrl;
  TeacherSubject? _subject;
  late String _examType;
  String? _difficulty;
  late bool _isPublished;
  late bool _showResultImmediately;
  bool _saving = false;

  bool get _isEdit => widget.existingExam != null;

  @override
  void initState() {
    super.initState();
    final exam = widget.existingExam;
    _titleCtrl = TextEditingController(text: exam?.titleAr ?? '');
    _descCtrl = TextEditingController(text: exam?.descriptionAr ?? '');
    _durationCtrl = TextEditingController(text: exam?.durationMinutes.toString() ?? '');
    _totalMarksCtrl = TextEditingController(text: exam?.totalMarks.toString() ?? '');
    _passMarksCtrl = TextEditingController(text: exam?.passMarks?.toString() ?? '');
    _subject = exam?.subject;
    _examType = exam?.examType ?? kExamTypes.first;
    _difficulty = exam?.difficultyLevel;
    _isPublished = exam?.isPublished ?? false;
    _showResultImmediately = exam?.showResultImmediately ?? true;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _durationCtrl.dispose();
    _totalMarksCtrl.dispose();
    _passMarksCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isEdit && _subject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر المادة أولاً', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.error),
      );
      return;
    }
    setState(() => _saving = true);
    final passMarks = _passMarksCtrl.text.trim().isEmpty ? null : int.tryParse(_passMarksCtrl.text.trim());

    if (_isEdit) {
      final cubit = context.read<TeacherExamDetailCubit>();
      final error = await cubit.updateMeta(
        titleAr: _titleCtrl.text.trim(),
        descriptionAr: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        examType: _examType,
        durationMinutes: int.parse(_durationCtrl.text.trim()),
        totalMarks: int.parse(_totalMarksCtrl.text.trim()),
        passMarks: passMarks,
        difficultyLevel: _difficulty,
        isPublished: _isPublished,
        showResultImmediately: _showResultImmediately,
      );
      if (!mounted) return;
      setState(() => _saving = false);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.error));
        return;
      }
      Navigator.of(context).pop();
      return;
    }

    final cubit = context.read<TeacherExamsCubit>();
    final result = await cubit.create(
      subjectId: _subject!.id,
      titleAr: _titleCtrl.text.trim(),
      descriptionAr: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      examType: _examType,
      durationMinutes: int.parse(_durationCtrl.text.trim()),
      totalMarks: int.parse(_totalMarksCtrl.text.trim()),
      passMarks: passMarks,
      difficultyLevel: _difficulty,
      isPublished: _isPublished,
      showResultImmediately: _showResultImmediately,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (result.error != null || result.exam == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error ?? 'تعذّر إنشاء الامتحان', style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.error),
      );
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => TeacherExamDetailPage(examId: result.exam!.id, className: widget.className),
      ),
    );
  }

  InputDecoration _decoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEdit ? 'تعديل الامتحان' : 'امتحان جديد', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 15)),
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
              decoration: _decoration('عنوان الامتحان'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'الرجاء إدخال العنوان' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _descCtrl,
              style: const TextStyle(fontFamily: 'Cairo'),
              maxLines: 2,
              decoration: _decoration('وصف (اختياري)'),
            ),
            const SizedBox(height: 14),
            if (!_isEdit)
              SubjectPickerField(
                classId: widget.classId!,
                selectedSubjectId: _subject?.id,
                onChanged: (s) => setState(() => _subject = s),
              )
            else if (_subject != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(12)),
                child: Text('المادة: ${_subject!.name}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary)),
              ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _examType,
              decoration: _decoration('نوع الامتحان'),
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textPrimary),
              items: kExamTypes.map((t) => DropdownMenuItem(value: t, child: Text(t.examTypeLabel, style: const TextStyle(fontFamily: 'Cairo')))).toList(),
              onChanged: (v) => setState(() => _examType = v ?? _examType),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _durationCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontFamily: 'Cairo'),
                    decoration: _decoration('المدة (دقيقة)'),
                    validator: (v) => (v == null || int.tryParse(v.trim()) == null) ? 'رقم غير صحيح' : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _totalMarksCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontFamily: 'Cairo'),
                    decoration: _decoration('العلامة الكاملة'),
                    validator: (v) => (v == null || int.tryParse(v.trim()) == null) ? 'رقم غير صحيح' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passMarksCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontFamily: 'Cairo'),
              decoration: _decoration('علامة النجاح (اختياري)'),
              validator: (v) => (v != null && v.trim().isNotEmpty && int.tryParse(v.trim()) == null) ? 'رقم غير صحيح' : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String?>(
              initialValue: _difficulty,
              decoration: _decoration('مستوى الصعوبة (اختياري)'),
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textPrimary),
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('بدون تحديد', style: TextStyle(fontFamily: 'Cairo'))),
                ...kDifficultyLevels.map((d) => DropdownMenuItem<String?>(value: d, child: Text(d.difficultyLabel, style: const TextStyle(fontFamily: 'Cairo')))),
              ],
              onChanged: (v) => setState(() => _difficulty = v),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _isPublished,
              onChanged: (v) => setState(() => _isPublished = v),
              activeThumbColor: AppColors.primary,
              title: const Text('نشر الامتحان', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 14)),
              subtitle: const Text('إذا لم يُفعّل، سيبقى الامتحان مسودة ولن يظهر للطلاب', style: TextStyle(fontFamily: 'Cairo', fontSize: 11.5, color: AppColors.textSecondary)),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _showResultImmediately,
              onChanged: (v) => setState(() => _showResultImmediately = v),
              activeThumbColor: AppColors.primary,
              title: const Text('إظهار النتيجة فوراً', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 14)),
              subtitle: const Text('عرض العلامة للطالب مباشرة بعد تسليم الامتحان', style: TextStyle(fontFamily: 'Cairo', fontSize: 11.5, color: AppColors.textSecondary)),
            ),
            const SizedBox(height: 24),
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
                  : Text(_isEdit ? 'حفظ التعديلات' : 'إنشاء الامتحان', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
