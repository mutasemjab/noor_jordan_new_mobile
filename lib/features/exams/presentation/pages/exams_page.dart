import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../cubit/exams_cubit.dart';
import '../cubit/exams_state.dart';
import '../../domain/entities/exam_entities.dart';

String examTypeLabel(String type) {
  switch (type) {
    case 'mock':
      return 'تجريبي';
    case 'unit':
      return 'وحدة';
    case 'final':
      return 'نهائي';
    case 'practice':
      return 'تدريبي';
    case 'previous_years':
      return 'أعوام سابقة';
    case 'placement':
      return 'تحديد مستوى';
    default:
      return type;
  }
}

class ExamsPage extends StatefulWidget {
  const ExamsPage({super.key});

  @override
  State<ExamsPage> createState() => _ExamsPageState();
}

class _ExamsPageState extends State<ExamsPage> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ExamsCubit>()..loadExams(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('الاختبارات', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 17)),
          centerTitle: true,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          bottom: TabBar(
            controller: _tabCtrl,
            labelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: AppColors.accent,
            indicatorWeight: 3,
            tabs: const [Tab(text: 'المتاحة'), Tab(text: 'نتائجي')],
          ),
        ),
        body: BlocBuilder<ExamsCubit, ExamsState>(
          builder: (context, state) {
            if (state is ExamsLoading || state is ExamStarting) return const ShimmerList();
            if (state is ExamsError) {
              return AppErrorWidget(message: state.message, onRetry: () => context.read<ExamsCubit>().loadExams());
            }
            if (state is ExamsLoaded) {
              return TabBarView(
                controller: _tabCtrl,
                children: [
                  _AvailableExamsList(exams: state.availableExams),
                  _MyExamsList(exams: state.myExams),
                ],
              );
            }
            return const ShimmerList();
          },
        ),
      ),
    );
  }
}

class _AvailableExamsList extends StatelessWidget {
  final List<Exam> exams;
  const _AvailableExamsList({required this.exams});

  @override
  Widget build(BuildContext context) {
    if (exams.isEmpty) {
      return const EmptyStateWidget(message: 'لا توجد اختبارات متاحة حالياً', icon: Icons.quiz_outlined);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: exams.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final exam = exams[i];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + i * 60),
          builder: (_, v, child) => Opacity(opacity: v, child: child),
          child: Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.push('/exams/${exam.id}', extra: exam),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(exam.title,
                              style: const TextStyle(
                                  fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                          child: Text(examTypeLabel(exam.examType),
                              style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.accentDark)),
                        ),
                      ],
                    ),
                    if (exam.subject != null) ...[
                      const SizedBox(height: 6),
                      Text(exam.subject!.name,
                          style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary)),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _InfoChip(icon: Icons.timer_outlined, label: '${exam.durationMinutes} دقيقة'),
                        const SizedBox(width: 8),
                        _InfoChip(icon: Icons.quiz_outlined, label: '${exam.totalQuestions} سؤال'),
                        const SizedBox(width: 8),
                        _InfoChip(icon: Icons.star_outline_rounded, label: '${exam.totalMarks} علامة'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MyExamsList extends StatelessWidget {
  final List<MyExam> exams;
  const _MyExamsList({required this.exams});

  @override
  Widget build(BuildContext context) {
    if (exams.isEmpty) {
      return const EmptyStateWidget(message: 'لم تقدّم أي اختبار بعد', icon: Icons.assignment_turned_in_outlined);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: exams.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final item = exams[i];
        final color = item.isPassed ? AppColors.present : AppColors.absent;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + i * 60),
          builder: (_, v, child) => Opacity(opacity: v, child: child),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(item.exam.title,
                            style: const TextStyle(
                                fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                        child: Text(item.isPassed ? 'ناجح' : 'راسب',
                            style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700, color: color)),
                      ),
                    ],
                  ),
                  if (item.exam.subject != null) ...[
                    const SizedBox(height: 6),
                    Text(item.exam.subject!.name,
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary)),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.grade_outlined,
                        label: '${item.score.toStringAsFixed(1)} / ${item.totalMarks.toStringAsFixed(0)}',
                        color: color,
                      ),
                      const SizedBox(width: 8),
                      _InfoChip(icon: Icons.percent_rounded, label: '${item.percentage.toStringAsFixed(1)}%', color: color),
                      if (item.timeTakenMinutes != null) ...[
                        const SizedBox(width: 8),
                        _InfoChip(icon: Icons.timer_outlined, label: '${item.timeTakenMinutes} د'),
                      ],
                    ],
                  ),
                  if (item.submittedAt != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'سُلّم بتاريخ ${DateFormat('d MMMM yyyy، h:mm a', 'ar').format(item.submittedAt!)}',
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _InfoChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color ?? AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: color ?? AppColors.textSecondary)),
      ],
    );
  }
}
