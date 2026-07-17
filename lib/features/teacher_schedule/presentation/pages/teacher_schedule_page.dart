import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../cubit/teacher_schedule_cubit.dart';
import '../cubit/teacher_schedule_state.dart';

class TeacherSchedulePage extends StatelessWidget {
  const TeacherSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TeacherScheduleCubit>()..load(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('جدولي'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<TeacherScheduleCubit, TeacherScheduleState>(
          builder: (context, state) {
            if (state is TeacherScheduleLoading) return const ShimmerList();
            if (state is TeacherScheduleError) {
              return AppErrorWidget(message: state.message, onRetry: () => context.read<TeacherScheduleCubit>().load());
            }
            if (state is TeacherScheduleLoaded) {
              if (state.schedule.isEmpty) {
                return const EmptyStateWidget(message: 'لا يوجد جدول متاح', icon: Icons.calendar_today_outlined);
              }
              final selectedDay = state.schedule[state.selectedDayIndex];
              return Column(
                children: [
                  // Day selector
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: state.schedule.length,
                        itemBuilder: (_, i) {
                          final isSelected = i == state.selectedDayIndex;
                          return GestureDetector(
                            onTap: () => context.read<TeacherScheduleCubit>().selectDay(i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
                              ),
                              child: Text(
                                state.schedule[i].dayName,
                                style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? Colors.white : AppColors.textSecondary),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  // Periods
                  Expanded(
                    child: selectedDay.periods.isEmpty
                        ? const EmptyStateWidget(message: 'لا توجد حصص لهذا اليوم', icon: Icons.event_busy_outlined)
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: selectedDay.periods.length,
                            itemBuilder: (_, i) {
                              final period = selectedDay.periods[i];
                              return TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: Duration(milliseconds: 300 + i * 80),
                                builder: (_, v, child) => Opacity(opacity: v, child: child),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppColors.divider),
                                    boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 4)],
                                  ),
                                  child: Row(
                                    children: [
                                      // Left period number bar
                                      Container(
                                        width: 56,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.07),
                                          borderRadius: const BorderRadius.only(
                                              topRight: Radius.circular(14), bottomRight: Radius.circular(14)),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('${period.periodNumber}',
                                                style: const TextStyle(
                                                    fontFamily: 'Cairo',
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w800,
                                                    color: AppColors.primary)),
                                            Text('حصة',
                                                style: const TextStyle(
                                                    fontFamily: 'Cairo', fontSize: 10, color: AppColors.textSecondary)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(period.subjectName,
                                                  style: const TextStyle(
                                                      fontFamily: 'Cairo',
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w700,
                                                      color: AppColors.textPrimary)),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primary.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Text(period.className,
                                                        style: const TextStyle(
                                                            fontFamily: 'Cairo',
                                                            fontSize: 11,
                                                            color: AppColors.primary,
                                                            fontWeight: FontWeight.w600)),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Icon(Icons.access_time_rounded, size: 12, color: AppColors.textSecondary),
                                                  const SizedBox(width: 4),
                                                  Text('${period.startTime} - ${period.endTime}',
                                                      style: const TextStyle(
                                                          fontFamily: 'Cairo', fontSize: 11, color: AppColors.textSecondary)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
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
