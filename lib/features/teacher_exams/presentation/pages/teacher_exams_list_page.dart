import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/teacher_exam.dart';
import '../cubit/teacher_exams_cubit.dart';
import '../cubit/teacher_exams_state.dart';
import 'teacher_exam_detail_page.dart';
import 'teacher_exam_form_page.dart';

class TeacherExamsListPage extends StatelessWidget {
  final int classId;
  final String className;

  const TeacherExamsListPage({super.key, required this.classId, required this.className});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TeacherExamsCubit>(param1: classId)..load(),
      child: _TeacherExamsView(classId: classId, className: className),
    );
  }
}

class _TeacherExamsView extends StatelessWidget {
  final int classId;
  final String className;
  const _TeacherExamsView({required this.classId, required this.className});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('الامتحانات — $className', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 15)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('امتحان جديد', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: Colors.white)),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<TeacherExamsCubit>(),
              child: TeacherExamFormPage(classId: classId, className: className),
            ),
          ),
        ),
      ),
      body: BlocBuilder<TeacherExamsCubit, TeacherExamsState>(
        builder: (context, state) {
          if (state is TeacherExamsLoading) return const ShimmerList();
          if (state is TeacherExamsError) {
            return AppErrorWidget(message: state.message, onRetry: () => context.read<TeacherExamsCubit>().load());
          }
          if (state is TeacherExamsLoaded) {
            if (state.exams.isEmpty) {
              return const EmptyStateWidget(message: 'لا توجد امتحانات بعد لهذا الصف', icon: Icons.quiz_outlined);
            }
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<TeacherExamsCubit>().load(),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.exams.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _ExamCard(exam: state.exams[i], className: className),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final TeacherExam exam;
  final String className;
  const _ExamCard({required this.exam, required this.className});

  Future<void> _confirmDelete(BuildContext context) async {
    final cubit = context.read<TeacherExamsCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('حذف الامتحان', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
        content: const Text('هل أنت متأكد من حذف هذا الامتحان بكل أسئلته؟', style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('حذف', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final error = await cubit.delete(exam.id);
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.error));
    }
  }

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
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => TeacherExamDetailPage(examId: exam.id, className: className)),
          );
          if (context.mounted) context.read<TeacherExamsCubit>().load();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: double.infinity, height: 3, color: exam.isPublished ? AppColors.present : AppColors.late),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.quiz_rounded, color: AppColors.error, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: (exam.isPublished ? AppColors.present : AppColors.late).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                exam.isPublished ? 'منشور' : 'مسودة',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: exam.isPublished ? AppColors.present : AppColors.late,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(exam.examType.examTypeLabel, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(exam.titleAr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text(
                          '${exam.totalQuestions} سؤال • ${exam.durationMinutes} دقيقة • ${exam.totalMarks} علامة',
                          style: const TextStyle(fontFamily: 'Cairo', fontSize: 11.5, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                    onPressed: () => _confirmDelete(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
