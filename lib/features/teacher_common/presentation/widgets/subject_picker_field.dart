import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/teacher_subject.dart';
import '../../domain/usecases/get_class_subjects_usecase.dart';

/// Dropdown that loads the subjects this teacher is assigned in [classId]
/// and lets the caller pick one (required before uploading a file, adding a
/// video, or creating an exam).
class SubjectPickerField extends StatefulWidget {
  final int classId;
  final int? selectedSubjectId;
  final ValueChanged<TeacherSubject?> onChanged;

  const SubjectPickerField({
    super.key,
    required this.classId,
    required this.selectedSubjectId,
    required this.onChanged,
  });

  @override
  State<SubjectPickerField> createState() => _SubjectPickerFieldState();
}

class _SubjectPickerFieldState extends State<SubjectPickerField> {
  late final Future<List<TeacherSubject>> _future;

  @override
  void initState() {
    super.initState();
    _future = sl<GetClassSubjectsUseCase>()(widget.classId).then(
      (either) => either.fold((f) => throw Exception(f.message), (subjects) => subjects),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TeacherSubject>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 54,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
          );
        }
        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
            ),
            child: const Text('تعذّر تحميل المواد', style: TextStyle(fontFamily: 'Cairo', color: AppColors.error, fontSize: 13)),
          );
        }
        final subjects = snapshot.data ?? [];
        if (subjects.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('لا توجد مواد مسندة لك بهذا الصف', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary)),
          );
        }
        return DropdownButtonFormField<int>(
          initialValue: widget.selectedSubjectId,
          decoration: InputDecoration(
            labelText: 'المادة',
            labelStyle: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
          ),
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textPrimary),
          items: subjects
              .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name, style: const TextStyle(fontFamily: 'Cairo'))))
              .toList(),
          onChanged: (id) {
            final subject = subjects.firstWhere((s) => s.id == id);
            widget.onChanged(subject);
          },
        );
      },
    );
  }
}
