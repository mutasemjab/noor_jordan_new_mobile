import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../domain/entities/schedule.dart';
import '../cubit/schedule_cubit.dart';
import '../cubit/schedule_state.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScheduleCubit(
        getSchedule: context.read(),
      )..load(),
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
            return _ScheduleContent(state: state);
          }
          return const _ScheduleShimmer();
        },
      ),
    );
  }
}

class _ScheduleContent extends StatelessWidget {
  final ScheduleLoaded state;
  const _ScheduleContent({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.schedule.isEmpty) {
      return const EmptyStateWidget(
        message: 'لا يوجد جدول دراسي متاح',
        icon: Icons.calendar_today_outlined,
      );
    }

    return Column(
      children: [
        _DaySelector(
          schedule: state.schedule,
          selectedIndex: state.selectedDayIndex,
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _PeriodsList(
              key: ValueKey(state.selectedDayIndex),
              periods: state.schedule[state.selectedDayIndex].periods,
            ),
          ),
        ),
      ],
    );
  }
}

class _DaySelector extends StatefulWidget {
  final List<DaySchedule> schedule;
  final int selectedIndex;
  const _DaySelector({
    required this.schedule,
    required this.selectedIndex,
  });

  @override
  State<_DaySelector> createState() => _DaySelectorState();
}

class _DaySelectorState extends State<_DaySelector> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void didUpdateWidget(_DaySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
  }

  void _scrollToSelected() {
    if (!_scrollController.hasClients) return;
    final chipWidth = 90.0;
    final targetOffset = widget.selectedIndex * chipWidth;
    final maxOffset = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      targetOffset.clamp(0.0, maxOffset),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 14),
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: List.generate(widget.schedule.length, (index) {
            final day = widget.schedule[index];
            final isSelected = index == widget.selectedIndex;
            return GestureDetector(
              onTap: () => context.read<ScheduleCubit>().selectDay(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? AppColors.accent : Colors.white38,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  day.dayName,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primary
                        : Colors.white,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _PeriodsList extends StatelessWidget {
  final List<Period> periods;
  const _PeriodsList({super.key, required this.periods});

  @override
  Widget build(BuildContext context) {
    if (periods.isEmpty) {
      return const EmptyStateWidget(
        message: 'لا توجد حصص في هذا اليوم',
        subMessage: 'استمتع بيومك!',
        icon: Icons.free_breakfast_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: periods.length,
      itemBuilder: (context, index) {
        return _AnimatedPeriodCard(
          period: periods[index],
          delay: Duration(milliseconds: index * 80),
        );
      },
    );
  }
}

class _AnimatedPeriodCard extends StatefulWidget {
  final Period period;
  final Duration delay;
  const _AnimatedPeriodCard({required this.period, required this.delay});

  @override
  State<_AnimatedPeriodCard> createState() => _AnimatedPeriodCardState();
}

class _AnimatedPeriodCardState extends State<_AnimatedPeriodCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: _PeriodCard(period: widget.period),
      ),
    );
  }
}

class _PeriodCard extends StatelessWidget {
  final Period period;
  const _PeriodCard({required this.period});

  Color _resolveSubjectColor() {
    if (period.subjectColor == null || period.subjectColor!.isEmpty) {
      return AppColors.primary;
    }
    final hex = period.subjectColor!.replaceAll('#', '');
    try {
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    } catch (_) {}
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final subjectColor = _resolveSubjectColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: subjectColor.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: subjectColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: subjectColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            period.label,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: subjectColor,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(Icons.access_time_outlined,
                                size: 13, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              '${period.startTime} - ${period.endTime}',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      period.subjectName,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _TeacherAvatar(
                          avatar: period.teacherAvatar,
                          name: period.teacherName,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            period.teacherName,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeacherAvatar extends StatelessWidget {
  final String? avatar;
  final String name;
  const _TeacherAvatar({required this.avatar, required this.name});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: AppColors.primary.withOpacity(0.1),
      child: ClipOval(
        child: avatar != null && avatar!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: avatar!,
                width: 28,
                height: 28,
                fit: BoxFit.cover,
                placeholder: (_, __) => const Icon(
                  Icons.person,
                  size: 14,
                  color: AppColors.primary,
                ),
                errorWidget: (_, __, ___) => const Icon(
                  Icons.person,
                  size: 14,
                  color: AppColors.primary,
                ),
              )
            : Center(
                child: Text(
                  name.isNotEmpty ? name[0] : 'م',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
      ),
    );
  }
}

class _ScheduleShimmer extends StatelessWidget {
  const _ScheduleShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Shimmer.fromColors(
          baseColor: AppColors.primary.withOpacity(0.6),
          highlightColor: AppColors.primary.withOpacity(0.3),
          child: Container(
            height: 60,
            color: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: List.generate(
                5,
                (i) => Container(
                  width: 72,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Shimmer.fromColors(
            baseColor: AppColors.divider,
            highlightColor: Colors.white,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              itemBuilder: (_, __) => Container(
                height: 100,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
