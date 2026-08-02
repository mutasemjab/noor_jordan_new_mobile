import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/teacher_exam.dart';
import '../cubit/teacher_exam_detail_cubit.dart';
import '../cubit/teacher_exam_detail_state.dart';
import 'teacher_exam_form_page.dart';
import 'teacher_exam_question_form_page.dart';

class TeacherExamDetailPage extends StatelessWidget {
  final int examId;
  final String className;

  const TeacherExamDetailPage({super.key, required this.examId, required this.className});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TeacherExamDetailCubit>(param1: examId)..load(),
      child: _TeacherExamDetailView(className: className),
    );
  }
}

class _TeacherExamDetailView extends StatelessWidget {
  final String className;
  const _TeacherExamDetailView({required this.className});

  Future<void> _confirmDeleteExam(BuildContext context) async {
    final cubit = context.read<TeacherExamDetailCubit>();
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
    final error = await cubit.deleteExam();
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.error));
      return;
    }
    Navigator.of(context).pop();
  }

  Future<void> _confirmDeleteQuestion(BuildContext context, int questionId) async {
    final cubit = context.read<TeacherExamDetailCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('حذف السؤال', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
        content: const Text('هل أنت متأكد من حذف هذا السؤال؟', style: TextStyle(fontFamily: 'Cairo')),
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
    final error = await cubit.deleteQuestion(questionId);
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('تفاصيل الامتحان', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 15)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          BlocBuilder<TeacherExamDetailCubit, TeacherExamDetailState>(
            builder: (context, state) {
              if (state is! TeacherExamDetailLoaded) return const SizedBox.shrink();
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<TeacherExamDetailCubit>(),
                          child: TeacherExamFormPage(className: className, existingExam: state.exam),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: () => _confirmDeleteExam(context),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      floatingActionButton: BlocBuilder<TeacherExamDetailCubit, TeacherExamDetailState>(
        builder: (context, state) {
          if (state is! TeacherExamDetailLoaded) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text('إضافة سؤال', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: Colors.white)),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<TeacherExamDetailCubit>(),
                  child: const TeacherExamQuestionFormPage(),
                ),
              ),
            ),
          );
        },
      ),
      body: BlocBuilder<TeacherExamDetailCubit, TeacherExamDetailState>(
        builder: (context, state) {
          if (state is TeacherExamDetailLoading) return const LoadingOverlay();
          if (state is TeacherExamDetailError) {
            return AppErrorWidget(message: state.message, onRetry: () => context.read<TeacherExamDetailCubit>().load());
          }
          if (state is TeacherExamDetailLoaded) {
            final exam = state.exam;
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<TeacherExamDetailCubit>().load(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _ExamSummaryCard(exam: exam),
                  const SizedBox(height: 20),
                  Text('الأسئلة (${exam.questions.length})', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
                  const SizedBox(height: 10),
                  if (exam.questions.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)),
                      child: const Text('لا توجد أسئلة بعد — اضغط "إضافة سؤال" للبدء', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary)),
                    )
                  else
                    ...List.generate(exam.questions.length, (i) {
                      final q = exam.questions[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _QuestionCard(
                          index: i + 1,
                          question: q,
                          onDelete: () => _confirmDeleteQuestion(context, q.id!),
                        ),
                      );
                    }),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ExamSummaryCard extends StatelessWidget {
  final TeacherExam exam;
  const _ExamSummaryCard({required this.exam});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(exam.titleAr, style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                child: Text(
                  exam.isPublished ? 'منشور' : 'مسودة',
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ],
          ),
          if (exam.descriptionAr != null && exam.descriptionAr!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(exam.descriptionAr!, style: TextStyle(fontFamily: 'Cairo', fontSize: 12.5, color: Colors.white.withOpacity(0.9))),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _MetaChip(icon: Icons.category_outlined, label: exam.examType.examTypeLabel),
              _MetaChip(icon: Icons.timer_outlined, label: '${exam.durationMinutes} دقيقة'),
              _MetaChip(icon: Icons.grade_outlined, label: '${exam.totalMarks} علامة'),
              if (exam.passMarks != null) _MetaChip(icon: Icons.check_circle_outline, label: 'النجاح: ${exam.passMarks}'),
              if (exam.difficultyLevel != null) _MetaChip(icon: Icons.speed_outlined, label: exam.difficultyLevel!.difficultyLabel),
              if (exam.subject != null) _MetaChip(icon: Icons.menu_book_outlined, label: exam.subject!.name),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: Colors.white),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.white)),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final int index;
  final TeacherExamQuestion question;
  final VoidCallback onDelete;
  const _QuestionCard({required this.index, required this.question, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<TeacherExamDetailCubit>(),
              child: TeacherExamQuestionFormPage(existingQuestion: question),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text('س$index', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(question.questionAr, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                    onPressed: onDelete,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${question.questionType.questionTypeLabel} • ${question.marks} علامة',
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              ...question.options.map(
                (o) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    children: [
                      Icon(o.isCorrect ? Icons.check_circle_rounded : Icons.circle_outlined, size: 14, color: o.isCorrect ? AppColors.present : AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          o.textAr,
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: o.isCorrect ? AppColors.present : AppColors.textSecondary, fontWeight: o.isCorrect ? FontWeight.w700 : FontWeight.normal),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
