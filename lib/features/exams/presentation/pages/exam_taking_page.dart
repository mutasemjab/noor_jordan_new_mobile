import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../cubit/exams_cubit.dart';
import '../cubit/exams_state.dart';

class ExamTakingPage extends StatelessWidget {
  const ExamTakingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExamsCubit, ExamsState>(
      listener: (context, state) {
        if (state is ExamResult) context.go('/exam-result');
        if (state is ExamsError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message, style: const TextStyle(fontFamily: 'Cairo')),
            backgroundColor: AppColors.error,
          ));
        }
      },
      child: BlocBuilder<ExamsCubit, ExamsState>(
        builder: (context, state) {
          if (state is! ExamTaking) {
            return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
          }
          final exam = state.exam;
          final questions = exam.questions;
          if (questions.isEmpty) {
            return Scaffold(
              appBar: AppBar(title: Text(exam.title), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              body: const Center(child: Text('لا توجد أسئلة في هذا الاختبار', style: TextStyle(fontFamily: 'Cairo'))),
            );
          }
          final question = questions[state.currentIndex];
          final selectedOption = state.answers[question.id];
          final timeLeft = state.timeLeft;
          final isLastQuestion = state.currentIndex == questions.length - 1;

          Color timerColor = AppColors.present;
          if (timeLeft.inMinutes < 5) {
            timerColor = AppColors.absent;
          } else if (timeLeft.inMinutes < 10) {
            timerColor = AppColors.late;
          }

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              title: Text(exam.title,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700)),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: timerColor == AppColors.present ? Colors.white : timerColor,
                    ),
                    child: Text(
                        '${timeLeft.inMinutes.toString().padLeft(2, '0')}:${(timeLeft.inSeconds % 60).toString().padLeft(2, '0')}'),
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                // Question indicators
                Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  child: SizedBox(
                    height: 28,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: questions.length,
                      itemBuilder: (_, i) {
                        final isAnswered = state.answers.containsKey(questions[i].id);
                        final isCurrent = i == state.currentIndex;
                        return GestureDetector(
                          onTap: () => context.read<ExamsCubit>().goToQuestion(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCurrent
                                  ? AppColors.primary
                                  : isAnswered
                                      ? AppColors.accent
                                      : Colors.white,
                              border: Border.all(
                                color: isCurrent ? AppColors.primary : isAnswered ? AppColors.accent : AppColors.divider,
                              ),
                            ),
                            child: Center(
                              child: Text('${i + 1}',
                                  style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isCurrent || isAnswered ? Colors.white : AppColors.textSecondary)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const Divider(height: 1, color: AppColors.divider),
                // Question content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question number + text
                        Text('السؤال ${state.currentIndex + 1} من ${questions.length}',
                            style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 10),
                        Text(question.questionText,
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                height: 1.6)),
                        const SizedBox(height: 24),
                        // Options
                        ...question.options.asMap().entries.map((entry) {
                          final option = entry.value;
                          final isSelected = selectedOption == option.id;
                          return GestureDetector(
                            onTap: () => context.read<ExamsCubit>().answerQuestion(question.id, option.id),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary.withOpacity(0.06) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.divider,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected ? AppColors.primary : Colors.transparent,
                                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.textSecondary),
                                    ),
                                    child: isSelected
                                        ? const Icon(Icons.check, color: Colors.white, size: 12)
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(option.text,
                                        style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 14,
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                            color: isSelected ? AppColors.primary : AppColors.textPrimary)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                // Navigation buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, -2))],
                  ),
                  child: Row(
                    children: [
                      if (state.currentIndex > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.read<ExamsCubit>().previousQuestion(),
                            child: const Text('السابق', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
                          ),
                        ),
                      if (state.currentIndex > 0) const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: isLastQuestion
                            ? ElevatedButton(
                                onPressed: () => _confirmSubmit(context, state),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accent,
                                    foregroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                child: const Text('تسليم الاختبار',
                                    style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
                              )
                            : ElevatedButton(
                                onPressed: () => context.read<ExamsCubit>().nextQuestion(),
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                child: const Text('التالي',
                                    style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmSubmit(BuildContext context, ExamTaking state) {
    final answered = state.answers.length;
    final total = state.exam.questions.length;
    final unanswered = total - answered;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('تسليم الاختبار', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('هل أنت متأكد من تسليم الاختبار؟',
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatChip(label: 'تمت الإجابة', value: '$answered', color: AppColors.present),
                _StatChip(label: 'بدون إجابة', value: '$unanswered', color: AppColors.absent),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ExamsCubit>().submitExam();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('تسليم', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}
