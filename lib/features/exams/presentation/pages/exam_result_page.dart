import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../cubit/exams_cubit.dart';
import '../cubit/exams_state.dart';

class ExamResultPage extends StatefulWidget {
  const ExamResultPage({super.key});

  @override
  State<ExamResultPage> createState() => _ExamResultPageState();
}

class _ExamResultPageState extends State<ExamResultPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _arcAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _arcAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: const Interval(0.5, 1, curve: Curves.easeIn));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExamsCubit, ExamsState>(
      builder: (context, state) {
        if (state is! ExamResult) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('النتيجة غير متاحة', style: TextStyle(fontFamily: 'Cairo', fontSize: 16)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/exams'),
                    child: const Text('العودة للاختبارات', style: TextStyle(fontFamily: 'Cairo')),
                  ),
                ],
              ),
            ),
          );
        }
        final attempt = state.attempt;
        final percentage = attempt.percentage ?? 0;
        final isPassed = attempt.isPassed ?? false;
        final correct = attempt.answers.where((a) => a.isCorrect == true).length;
        final wrong = attempt.answers.where((a) => a.isCorrect == false).length;
        final unanswered = attempt.answers.where((a) => a.isCorrect == null).length;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('نتيجة الاختبار'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Result header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: isPassed ? AppColors.present.withOpacity(0.08) : AppColors.absent.withOpacity(0.08),
                  ),
                  child: Column(
                    children: [
                      // Score arc
                      AnimatedBuilder(
                        animation: _arcAnim,
                        builder: (_, __) => SizedBox(
                          width: 160,
                          height: 160,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: _arcAnim.value * percentage / 100,
                                strokeWidth: 14,
                                backgroundColor: AppColors.divider,
                                valueColor: AlwaysStoppedAnimation(isPassed ? AppColors.present : AppColors.absent),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${(_arcAnim.value * percentage).toStringAsFixed(1)}%',
                                    style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        color: isPassed ? AppColors.present : AppColors.absent),
                                  ),
                                  Text(
                                    isPassed ? 'ناجح' : 'راسب',
                                    style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isPassed ? AppColors.present : AppColors.absent),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: Text(
                          isPassed ? 'ممتاز! لقد نجحت في الاختبار' : 'للأسف لم تجتز الاختبار هذه المرة',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isPassed ? AppColors.present : AppColors.absent),
                        ),
                      ),
                    ],
                  ),
                ),
                // Stats
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      _ResultStat(label: 'صحيح', value: '$correct', color: AppColors.present, icon: Icons.check_circle_rounded),
                      _ResultStat(label: 'خطأ', value: '$wrong', color: AppColors.absent, icon: Icons.cancel_rounded),
                      _ResultStat(label: 'بدون إجابة', value: '$unanswered', color: AppColors.textSecondary, icon: Icons.radio_button_unchecked_rounded),
                    ],
                  ),
                ),
                // Answer review
                if (attempt.answers.isNotEmpty) ...[
                  const Divider(color: AppColors.divider),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('مراجعة الإجابات',
                            style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(height: 12),
                        ...attempt.answers.asMap().entries.map((e) {
                          final i = e.key;
                          final a = e.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: a.isCorrect == true
                                  ? AppColors.present.withOpacity(0.08)
                                  : a.isCorrect == false
                                      ? AppColors.absent.withOpacity(0.08)
                                      : AppColors.divider.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  a.isCorrect == true ? Icons.check_circle : a.isCorrect == false ? Icons.cancel : Icons.circle_outlined,
                                  color: a.isCorrect == true ? AppColors.present : a.isCorrect == false ? AppColors.absent : AppColors.textSecondary,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text('السؤال ${i + 1}',
                                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textPrimary)),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => context.go('/exams'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('العودة للاختبارات',
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _ResultStat({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
