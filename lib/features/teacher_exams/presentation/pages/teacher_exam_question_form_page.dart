import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/teacher_exam.dart';
import '../cubit/teacher_exam_detail_cubit.dart';

class TeacherExamQuestionFormPage extends StatefulWidget {
  final TeacherExamQuestion? existingQuestion;
  const TeacherExamQuestionFormPage({super.key, this.existingQuestion});

  @override
  State<TeacherExamQuestionFormPage> createState() => _TeacherExamQuestionFormPageState();
}

class _OptionField {
  final TextEditingController controller;
  bool isCorrect;
  _OptionField({required String text, required this.isCorrect}) : controller = TextEditingController(text: text);
}

class _TeacherExamQuestionFormPageState extends State<TeacherExamQuestionFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _questionCtrl;
  late final TextEditingController _marksCtrl;
  late final TextEditingController _explanationCtrl;
  late String _questionType;
  String? _difficulty;
  late List<_OptionField> _options;
  bool _saving = false;
  String? _optionsError;

  bool get _isEdit => widget.existingQuestion != null;

  @override
  void initState() {
    super.initState();
    final q = widget.existingQuestion;
    _questionCtrl = TextEditingController(text: q?.questionAr ?? '');
    _marksCtrl = TextEditingController(text: q?.marks.toString() ?? '5');
    _explanationCtrl = TextEditingController(text: q?.explanationAr ?? '');
    _questionType = q?.questionType ?? 'mcq';
    _difficulty = q?.difficulty;
    if (q != null) {
      _options = q.options.map((o) => _OptionField(text: o.textAr, isCorrect: o.isCorrect)).toList();
    } else {
      _options = _questionType == 'true_false'
          ? [_OptionField(text: 'صح', isCorrect: true), _OptionField(text: 'خطأ', isCorrect: false)]
          : [_OptionField(text: '', isCorrect: false), _OptionField(text: '', isCorrect: false)];
    }
  }

  @override
  void dispose() {
    _questionCtrl.dispose();
    _marksCtrl.dispose();
    _explanationCtrl.dispose();
    for (final o in _options) {
      o.controller.dispose();
    }
    super.dispose();
  }

  void _onTypeChanged(String type) {
    setState(() {
      _questionType = type;
      if (type == 'true_false') {
        for (final o in _options) {
          o.controller.dispose();
        }
        _options = [
          _OptionField(text: 'صح', isCorrect: true),
          _OptionField(text: 'خطأ', isCorrect: false),
        ];
      } else if (_options.length != 2 || _options.any((o) => o.controller.text == 'صح' || o.controller.text == 'خطأ')) {
        for (final o in _options) {
          o.controller.dispose();
        }
        _options = [_OptionField(text: '', isCorrect: false), _OptionField(text: '', isCorrect: false)];
      }
    });
  }

  void _addOption() {
    setState(() => _options.add(_OptionField(text: '', isCorrect: false)));
  }

  void _removeOption(int index) {
    setState(() {
      _options[index].controller.dispose();
      _options.removeAt(index);
    });
  }

  void _selectCorrect(int index) {
    setState(() {
      for (var i = 0; i < _options.length; i++) {
        _options[i].isCorrect = i == index;
      }
    });
  }

  bool _validateOptions() {
    if (_questionType == 'true_false' && _options.length != 2) {
      setState(() => _optionsError = 'سؤال صح وخطأ يجب أن يحتوي خيارين بالضبط');
      return false;
    }
    if (_options.length < 2) {
      setState(() => _optionsError = 'يجب إضافة خيارين على الأقل');
      return false;
    }
    if (_options.any((o) => o.controller.text.trim().isEmpty)) {
      setState(() => _optionsError = 'يرجى تعبئة نص كل الخيارات');
      return false;
    }
    if (_options.where((o) => o.isCorrect).length != 1) {
      setState(() => _optionsError = 'يرجى تحديد إجابة صحيحة واحدة بالضبط');
      return false;
    }
    setState(() => _optionsError = null);
    return true;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_validateOptions()) return;

    final question = TeacherExamQuestion(
      questionAr: _questionCtrl.text.trim(),
      questionType: _questionType,
      marks: int.parse(_marksCtrl.text.trim()),
      difficulty: _difficulty,
      explanationAr: _explanationCtrl.text.trim().isEmpty ? null : _explanationCtrl.text.trim(),
      options: _options.map((o) => TeacherExamOption(textAr: o.controller.text.trim(), isCorrect: o.isCorrect)).toList(),
    );

    setState(() => _saving = true);
    final cubit = context.read<TeacherExamDetailCubit>();
    final error = _isEdit ? await cubit.updateQuestion(widget.existingQuestion!.id!, question) : await cubit.addQuestion(question);
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEdit ? 'تعديل السؤال' : 'سؤال جديد', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 15)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _questionCtrl,
              style: const TextStyle(fontFamily: 'Cairo'),
              maxLines: 3,
              decoration: _decoration('نص السؤال'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'الرجاء إدخال نص السؤال' : null,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('اختيار من متعدد', style: TextStyle(fontFamily: 'Cairo', fontSize: 12)),
                    selected: _questionType == 'mcq',
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(color: _questionType == 'mcq' ? Colors.white : AppColors.textPrimary, fontFamily: 'Cairo'),
                    onSelected: (_) => _onTypeChanged('mcq'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('صح وخطأ', style: TextStyle(fontFamily: 'Cairo', fontSize: 12)),
                    selected: _questionType == 'true_false',
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(color: _questionType == 'true_false' ? Colors.white : AppColors.textPrimary, fontFamily: 'Cairo'),
                    onSelected: (_) => _onTypeChanged('true_false'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _marksCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontFamily: 'Cairo'),
              decoration: _decoration('علامة السؤال'),
              validator: (v) => (v == null || int.tryParse(v.trim()) == null) ? 'رقم غير صحيح' : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String?>(
              initialValue: _difficulty,
              decoration: _decoration('مستوى الصعوبة (اختياري)'),
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textPrimary),
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('بدون تحديد', style: TextStyle(fontFamily: 'Cairo'))),
                ...kQuestionDifficultyLevels.map((d) => DropdownMenuItem<String?>(value: d, child: Text(d.difficultyLabel, style: const TextStyle(fontFamily: 'Cairo')))),
              ],
              onChanged: (v) => setState(() => _difficulty = v),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _explanationCtrl,
              style: const TextStyle(fontFamily: 'Cairo'),
              maxLines: 2,
              decoration: _decoration('شرح الإجابة (اختياري)'),
            ),
            const SizedBox(height: 20),
            Text('الخيارات — حدد الإجابة الصحيحة', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            ...List.generate(_options.length, (i) {
              final option = _options[i];
              final isFixedTrueFalse = _questionType == 'true_false';
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Radio<int>(
                      value: i,
                      groupValue: _options.indexWhere((o) => o.isCorrect) == -1 ? null : _options.indexWhere((o) => o.isCorrect),
                      onChanged: (_) => _selectCorrect(i),
                      activeColor: AppColors.present,
                    ),
                    Expanded(
                      child: TextField(
                        controller: option.controller,
                        readOnly: isFixedTrueFalse,
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'نص الخيار ${i + 1}',
                          hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
                          isDense: true,
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.divider)),
                        ),
                      ),
                    ),
                    if (!isFixedTrueFalse && _options.length > 2)
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.error, size: 20),
                        onPressed: () => _removeOption(i),
                      ),
                  ],
                ),
              );
            }),
            if (_questionType == 'mcq')
              TextButton.icon(
                onPressed: _addOption,
                icon: const Icon(Icons.add_rounded, color: AppColors.primary, size: 18),
                label: const Text('إضافة خيار', style: TextStyle(fontFamily: 'Cairo', color: AppColors.primary)),
              ),
            if (_optionsError != null) ...[
              const SizedBox(height: 4),
              Text(_optionsError!, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.error)),
            ],
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
                  : Text(_isEdit ? 'حفظ السؤال' : 'إضافة السؤال', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
