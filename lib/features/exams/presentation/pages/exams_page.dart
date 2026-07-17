import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../cubit/exams_cubit.dart';
import '../cubit/exams_state.dart';
import '../../domain/entities/exam_entities.dart';

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
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ExamsCubit>()..loadMyExams(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('الاختبارات'),
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
            tabs: const [Tab(text: 'الكل'), Tab(text: 'جارية'), Tab(text: 'مكتملة')],
          ),
        ),
        body: BlocBuilder<ExamsCubit, ExamsState>(
          builder: (context, state) {
            if (state is ExamsLoading || state is ExamStarting) return const ShimmerList();
            if (state is ExamsError) {
              return AppErrorWidget(message: state.message, onRetry: () => context.read<ExamsCubit>().loadMyExams());
            }
            if (state is ExamsLoaded) {
              final all = state.myExams;
              final active = all.where((e) => e.exam.status == 'active' || e.exam.status == 'available').toList();
              final completed = all.where((e) => e.submittedAt != null || e.isPassed != null).toList();
              return TabBarView(
                controller: _tabCtrl,
                children: [
                  _ExamList(exams: all),
                  _ExamList(exams: active, emptyMessage: 'لا توجد اختبارات جارية'),
                  _ExamList(exams: completed, emptyMessage: 'لا توجد اختبارات مكتملة'),
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

class _ExamList extends StatelessWidget {
  final List<MyExam> exams;
  final String emptyMessage;
  const _ExamList({required this.exams, this.emptyMessage = 'لا توجد اختبارات'});

  @override
  Widget build(BuildContext context) {
    if (exams.isEmpty) return EmptyStateWidget(message: emptyMessage, icon: Icons.quiz_outlined);
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: exams.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final item = exams[i];
        final isCompleted = item.isPassed != null;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + i * 60),
          builder: (_, v, child) => Opacity(opacity: v, child: child),
          child: Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.push('/exams/${item.exam.id}', extra: item.exam),
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
                                  fontFamily: 'Cairo',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                        ),
                        _StatusBadge(status: item.exam.status, isPassed: item.isPassed),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _InfoChip(icon: Icons.timer_outlined, label: '${item.exam.durationMinutes} دقيقة'),
                        const SizedBox(width: 8),
                        _InfoChip(icon: Icons.quiz_outlined, label: '${item.exam.questionsCount} سؤال'),
                        if (isCompleted) ...[
                          const SizedBox(width: 8),
                          _InfoChip(
                            icon: Icons.grade_outlined,
                            label: '${item.percentage?.toStringAsFixed(1)}%',
                            color: (item.isPassed ?? false) ? AppColors.present : AppColors.absent,
                          ),
                        ],
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

class _StatusBadge extends StatelessWidget {
  final String status;
  final bool? isPassed;
  const _StatusBadge({required this.status, this.isPassed});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    String label;
    if (isPassed != null) {
      bg = isPassed! ? AppColors.present.withOpacity(0.1) : AppColors.absent.withOpacity(0.1);
      text = isPassed! ? AppColors.present : AppColors.absent;
      label = isPassed! ? 'ناجح' : 'راسب';
    } else if (status == 'active' || status == 'available') {
      bg = AppColors.accent.withOpacity(0.1);
      text = AppColors.accentDark;
      label = 'متاح';
    } else {
      bg = AppColors.divider;
      text = AppColors.textSecondary;
      label = 'غير متاح';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700, color: text)),
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
