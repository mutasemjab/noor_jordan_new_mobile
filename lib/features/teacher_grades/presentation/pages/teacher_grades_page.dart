import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../teacher_common/domain/entities/teacher_subject.dart';
import '../../../teacher_common/presentation/widgets/subject_picker_field.dart';
import '../../domain/entities/teacher_grades.dart';
import '../cubit/teacher_grades_cubit.dart';
import '../cubit/teacher_grades_state.dart';
import 'teacher_grade_entry_form_page.dart';

class TeacherGradesPage extends StatelessWidget {
  final int classId;
  final String className;

  const TeacherGradesPage({super.key, required this.classId, required this.className});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TeacherGradesCubit>(param1: classId),
      child: _TeacherGradesView(classId: classId, className: className),
    );
  }
}

/// One graded exam, derived client-side by grouping [GradeRecord]s by title
/// — the backend has no separate "exam" entity, so this is purely a display
/// aggregation over the flat records list.
class _ExamSummary {
  final String title;
  final double maxScore;
  final DateTime? gradedAt;
  final List<GradeRecord> entries;

  const _ExamSummary({required this.title, required this.maxScore, required this.gradedAt, required this.entries});

  double get average => entries.isEmpty ? 0 : entries.map((e) => e.score).reduce((a, b) => a + b) / entries.length;
}

List<_ExamSummary> _groupByTitle(List<GradeRecord> records) {
  final byTitle = <String, List<GradeRecord>>{};
  for (final r in records) {
    byTitle.putIfAbsent(r.title, () => []).add(r);
  }
  final summaries = byTitle.entries
      .map((e) => _ExamSummary(
            title: e.key,
            maxScore: e.value.first.maxScore,
            gradedAt: e.value.first.gradedAt,
            entries: e.value,
          ))
      .toList();
  summaries.sort((a, b) {
    if (a.gradedAt == null || b.gradedAt == null) return 0;
    return b.gradedAt!.compareTo(a.gradedAt!);
  });
  return summaries;
}

class _TeacherGradesView extends StatefulWidget {
  final int classId;
  final String className;
  const _TeacherGradesView({required this.classId, required this.className});

  @override
  State<_TeacherGradesView> createState() => _TeacherGradesViewState();
}

class _TeacherGradesViewState extends State<_TeacherGradesView> {
  TeacherSubject? _selectedSubject;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('العلامات — ${widget.className}', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 15)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: _selectedSubject == null
          ? null
          : FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text('علامات جديدة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: Colors.white)),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<TeacherGradesCubit>(),
                    child: const TeacherGradeEntryFormPage(),
                  ),
                ),
              ),
            ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SubjectPickerField(
              classId: widget.classId,
              selectedSubjectId: _selectedSubject?.id,
              onChanged: (subject) {
                setState(() => _selectedSubject = subject);
                if (subject != null) context.read<TeacherGradesCubit>().selectSubject(subject);
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _selectedSubject == null
                  ? const EmptyStateWidget(message: 'اختر المادة لعرض العلامات', icon: Icons.grading_outlined)
                  : BlocBuilder<TeacherGradesCubit, TeacherGradesState>(
                      builder: (context, state) {
                        if (state is TeacherGradesLoading || state is TeacherGradesInitial) return const ShimmerList();
                        if (state is TeacherGradesError) {
                          return AppErrorWidget(
                            message: state.message,
                            onRetry: () => context.read<TeacherGradesCubit>().selectSubject(_selectedSubject!),
                          );
                        }
                        if (state is TeacherGradesLoaded) {
                          final summaries = _groupByTitle(state.records);
                          if (summaries.isEmpty) {
                            return const EmptyStateWidget(message: 'لا توجد علامات مسجّلة بعد لهذه المادة', icon: Icons.grading_outlined);
                          }
                          return RefreshIndicator(
                            color: AppColors.primary,
                            onRefresh: () => context.read<TeacherGradesCubit>().refresh(),
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 90),
                              itemCount: summaries.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (_, i) => _ExamSummaryCard(summary: summaries[i]),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamSummaryCard extends StatelessWidget {
  final _ExamSummary summary;
  const _ExamSummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<TeacherGradesCubit>(),
              child: TeacherGradeEntryFormPage(existingTitle: summary.title),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.grading_rounded, color: AppColors.accentDark, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(summary.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(
                      '${summary.entries.length} طالب • من ${summary.maxScore.toStringAsFixed(0)} • المعدل ${summary.average.toStringAsFixed(1)}'
                      '${summary.gradedAt != null ? ' • ${DateFormat('d MMM yyyy', 'ar').format(summary.gradedAt!)}' : ''}',
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 11.5, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
