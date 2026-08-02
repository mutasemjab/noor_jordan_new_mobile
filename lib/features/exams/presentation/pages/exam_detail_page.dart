import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../cubit/exams_cubit.dart';
import '../cubit/exams_state.dart';
import 'exams_page.dart' show examTypeLabel;
import '../../domain/entities/exam_entities.dart';

class ExamDetailPage extends StatelessWidget {
  final Exam? exam;
  const ExamDetailPage({super.key, this.exam});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExamsCubit, ExamsState>(
      listener: (context, state) {
        if (state is ExamTaking) {
          context.go('/exam-taking');
        } else if (state is ExamsError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message, style: const TextStyle(fontFamily: 'Cairo')),
            backgroundColor: AppColors.error,
          ));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(exam?.title ?? 'الاختبار'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: exam == null
            ? const Center(child: Text('لا تتوفر بيانات الاختبار', style: TextStyle(fontFamily: 'Cairo')))
            : SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.quiz_rounded, color: Colors.white, size: 48),
                            const SizedBox(height: 12),
                            Text(exam!.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(examTypeLabel(exam!.examType),
                                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (exam!.subject != null) ...[
                        _DetailCard(label: 'المادة', value: exam!.subject!.name, icon: Icons.menu_book_outlined),
                        const SizedBox(height: 12),
                      ],
                      if (exam!.description != null && exam!.description!.isNotEmpty) ...[
                        Text(exam!.description!,
                            style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary, height: 1.6)),
                        const SizedBox(height: 16),
                      ],
                      _DetailCard(label: 'عدد الأسئلة', value: '${exam!.totalQuestions} سؤال', icon: Icons.quiz_outlined),
                      const SizedBox(height: 12),
                      _DetailCard(label: 'مدة الاختبار', value: '${exam!.durationMinutes} دقيقة', icon: Icons.timer_outlined),
                      const SizedBox(height: 12),
                      _DetailCard(label: 'العلامة الكاملة', value: '${exam!.totalMarks} علامة', icon: Icons.star_outline_rounded),
                      if (exam!.passMarks != null) ...[
                        const SizedBox(height: 12),
                        _DetailCard(label: 'علامة النجاح', value: '${exam!.passMarks} علامة', icon: Icons.check_circle_outline),
                      ],
                      if (exam!.difficultyLevel != null) ...[
                        const SizedBox(height: 12),
                        _DetailCard(label: 'مستوى الصعوبة', value: exam!.difficultyLevel!, icon: Icons.speed_outlined),
                      ],
                      const SizedBox(height: 32),
                      BlocBuilder<ExamsCubit, ExamsState>(
                        builder: (context, state) => SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: state is ExamStarting
                                ? null
                                : () => context.read<ExamsCubit>().startExam(exam!.id, exam!),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: state is ExamStarting
                                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary))
                                : const Text('بدء الاختبار',
                                    style: TextStyle(fontFamily: 'Cairo', fontSize: 17, fontWeight: FontWeight.w700)),
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

class _DetailCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _DetailCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary)),
            const Spacer(),
            Text(value,
                style: const TextStyle(
                    fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
