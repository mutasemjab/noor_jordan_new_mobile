import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/teacher_grades.dart';
import '../cubit/teacher_grades_cubit.dart';
import '../cubit/teacher_grades_state.dart';

/// Create-or-edit form for one exam's grades. When [existingTitle] is set,
/// this pre-fills from the matching records in the already-loaded cubit
/// state (edit mode); otherwise it's a blank "new exam" entry.
class TeacherGradeEntryFormPage extends StatefulWidget {
  final String? existingTitle;
  const TeacherGradeEntryFormPage({super.key, this.existingTitle});

  @override
  State<TeacherGradeEntryFormPage> createState() => _TeacherGradeEntryFormPageState();
}

class _TeacherGradeEntryFormPageState extends State<TeacherGradeEntryFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _maxScoreCtrl;
  late DateTime _gradedAt;
  final Map<int, TextEditingController> _scoreControllers = {};
  bool _saving = false;

  bool get _isEdit => widget.existingTitle != null;

  @override
  void initState() {
    super.initState();
    final state = context.read<TeacherGradesCubit>().state;
    final roster = state is TeacherGradesLoaded ? state.roster : const [];
    final existingRecords = (state is TeacherGradesLoaded && widget.existingTitle != null)
        ? state.records.where((r) => r.title == widget.existingTitle).toList()
        : const <GradeRecord>[];

    _titleCtrl = TextEditingController(text: widget.existingTitle ?? '');
    _maxScoreCtrl = TextEditingController(
      text: existingRecords.isNotEmpty ? existingRecords.first.maxScore.toStringAsFixed(0) : '',
    );
    _gradedAt = existingRecords.isNotEmpty && existingRecords.first.gradedAt != null
        ? existingRecords.first.gradedAt!
        : DateTime.now();

    for (final student in roster) {
      final match = existingRecords.where((r) => r.studentId == student.id);
      final score = match.isEmpty ? null : match.first.score;
      _scoreControllers[student.id] = TextEditingController(text: score?.toStringAsFixed(0) ?? '');
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _maxScoreCtrl.dispose();
    for (final c in _scoreControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _gradedAt,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _gradedAt = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final maxScore = double.tryParse(_maxScoreCtrl.text.trim());
    if (maxScore == null || maxScore <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال الدرجة الكاملة', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.error),
      );
      return;
    }

    final grades = <GradeEntryInput>[];
    for (final entry in _scoreControllers.entries) {
      final text = entry.value.text.trim();
      if (text.isEmpty) continue;
      final score = double.tryParse(text);
      if (score == null) continue;
      if (score > maxScore) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('علامة أحد الطلاب أكبر من الدرجة الكاملة', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.error),
        );
        return;
      }
      grades.add(GradeEntryInput(studentId: entry.key, score: score));
    }
    if (grades.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل علامة طالب واحد على الأقل', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _saving = true);
    final error = await context.read<TeacherGradesCubit>().submit(
          title: _titleCtrl.text.trim(),
          maxScore: maxScore,
          gradedAt: _gradedAt,
          grades: grades,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.error));
      return;
    }
    Navigator.of(context).pop();
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
    final state = context.watch<TeacherGradesCubit>().state;
    final roster = state is TeacherGradesLoaded ? state.roster : const [];
    final existingTitles = state is TeacherGradesLoaded
        ? state.records.map((r) => r.title).toSet().toList()
        : const <String>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEdit ? 'تعديل العلامات' : 'علامات جديدة', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 15)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_isEdit)
              TextFormField(
                controller: _titleCtrl,
                readOnly: true,
                style: const TextStyle(fontFamily: 'Cairo'),
                decoration: _decoration('اسم الاختبار'),
              )
            else
              Autocomplete<String>(
                optionsBuilder: (value) {
                  if (value.text.isEmpty) return const Iterable<String>.empty();
                  return existingTitles.where((t) => t.contains(value.text));
                },
                onSelected: (selection) => _titleCtrl.text = selection,
                fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                  controller.text = _titleCtrl.text;
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    style: const TextStyle(fontFamily: 'Cairo'),
                    decoration: _decoration('اسم الاختبار'),
                    onChanged: (v) => _titleCtrl.text = v,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'الرجاء إدخال اسم الاختبار' : null,
                  );
                },
              ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _maxScoreCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontFamily: 'Cairo'),
                    decoration: _decoration('الدرجة الكاملة'),
                    validator: (v) => (v == null || double.tryParse(v.trim()) == null) ? 'رقم غير صحيح' : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: _decoration('تاريخ الاختبار'),
                      child: Text(
                        '${_gradedAt.year}-${_gradedAt.month.toString().padLeft(2, '0')}-${_gradedAt.day.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('علامات الطلاب', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            ...roster.map((student) {
              final controller = _scoreControllers[student.id]!;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(student.name, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: controller,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            border: OutlineInputBorder(),
                          ),
                          style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
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
                  : const Text('حفظ العلامات', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
