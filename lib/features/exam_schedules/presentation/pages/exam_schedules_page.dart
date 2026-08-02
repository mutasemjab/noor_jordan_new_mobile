import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/fullscreen_image_viewer.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/exam_schedule.dart';
import '../cubit/exam_schedules_cubit.dart';
import '../cubit/exam_schedules_state.dart';

class ExamSchedulesPage extends StatelessWidget {
  const ExamSchedulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ExamSchedulesCubit>()..load(),
      child: const _ExamSchedulesView(),
    );
  }
}

class _ExamSchedulesView extends StatelessWidget {
  const _ExamSchedulesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'جداول الامتحانات',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<ExamSchedulesCubit, ExamSchedulesState>(
        builder: (context, state) {
          if (state is ExamSchedulesLoading) {
            return const ShimmerList(itemCount: 4, itemHeight: 180);
          }
          if (state is ExamSchedulesError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context.read<ExamSchedulesCubit>().load(),
            );
          }
          if (state is ExamSchedulesLoaded) {
            if (state.items.isEmpty) {
              return const EmptyStateWidget(
                message: 'لا توجد جداول امتحانات حالياً',
                icon: Icons.event_note_outlined,
              );
            }
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<ExamSchedulesCubit>().load(),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: state.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (_, i) => _ExamScheduleCard(item: state.items[i]),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ExamScheduleCard extends StatelessWidget {
  final ExamSchedule item;
  const _ExamScheduleCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final heroTag = 'exam-schedule-${item.id}';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => FullscreenImageViewer.open(
              context,
              item.image,
              heroTag: heroTag,
              title: item.name,
            ),
            child: Hero(
              tag: heroTag,
              child: CachedNetworkImage(
                imageUrl: item.image,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: 180,
                  color: AppColors.divider,
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 180,
                  color: AppColors.divider,
                  child: const Icon(Icons.image_not_supported_outlined,
                      color: AppColors.textSecondary, size: 36),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.className ?? 'لجميع الصفوف',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textSecondary.withOpacity(0.8)),
                    const SizedBox(width: 4),
                    Text(
                      item.createdAt,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: AppColors.textSecondary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
