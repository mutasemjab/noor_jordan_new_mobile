import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/fullscreen_image_viewer.dart';
import '../../domain/entities/schedule.dart';
import '../cubit/schedule_cubit.dart';
import '../cubit/schedule_state.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ScheduleCubit>()..load(),
      child: const _ScheduleView(),
    );
  }
}

class _ScheduleView extends StatelessWidget {
  const _ScheduleView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'الجدول الدراسي',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<ScheduleCubit, ScheduleState>(
        builder: (context, state) {
          if (state is ScheduleLoading) {
            return const _ScheduleShimmer();
          }
          if (state is ScheduleError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context.read<ScheduleCubit>().load(),
            );
          }
          if (state is ScheduleLoaded) {
            return _ScheduleContent(schedule: state.schedule);
          }
          return const _ScheduleShimmer();
        },
      ),
    );
  }
}

class _ScheduleContent extends StatelessWidget {
  final ClassSchedule schedule;
  const _ScheduleContent({required this.schedule});

  static const _heroTag = 'class-schedule-image';

  @override
  Widget build(BuildContext context) {
    final imageUrl = schedule.scheduleImage;

    if (imageUrl == null || imageUrl.isEmpty) {
      return EmptyStateWidget(
        message: 'لم يتم رفع الجدول الدراسي بعد',
        subMessage: schedule.className,
        icon: Icons.calendar_today_outlined,
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => context.read<ScheduleCubit>().load(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              schedule.className,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => FullscreenImageViewer.open(
                context,
                imageUrl,
                heroTag: _heroTag,
                title: schedule.className,
              ),
              child: Hero(
                tag: _heroTag,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => Container(
                      height: 220,
                      color: AppColors.divider,
                      child: const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 220,
                      color: AppColors.divider,
                      child: const Icon(Icons.image_not_supported_outlined,
                          color: AppColors.textSecondary, size: 40),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pinch_outlined, size: 14, color: AppColors.textSecondary.withOpacity(0.8)),
                const SizedBox(width: 6),
                Text(
                  'اضغط على الصورة للتكبير والتنزيل',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: AppColors.textSecondary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleShimmer extends StatelessWidget {
  const _ScheduleShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.divider,
      highlightColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 18, width: 140, color: AppColors.divider),
            const SizedBox(height: 16),
            Container(
              height: 320,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
