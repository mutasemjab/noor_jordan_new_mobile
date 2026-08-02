import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/fullscreen_image_viewer.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../classes/domain/entities/school_class.dart';
import '../../../home/domain/entities/home_data.dart' as home_data show Banner;
import '../../domain/entities/teacher_home_data.dart';
import '../cubit/teacher_home_cubit.dart';
import '../cubit/teacher_home_state.dart';

class TeacherHomePage extends StatelessWidget {
  const TeacherHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TeacherHomeCubit>()..load(),
      child: const _TeacherHomeView(),
    );
  }
}

class _TeacherHomeView extends StatelessWidget {
  const _TeacherHomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'مدارس نور الأردن الدولية',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white),
            onPressed: () => context.push('/teacher-messages'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded, color: Colors.white),
            onPressed: () => context.push('/teacher-profile'),
          ),
        ],
      ),
      body: BlocBuilder<TeacherHomeCubit, TeacherHomeState>(
        builder: (context, state) {
          if (state is TeacherHomeLoading) {
            return const ShimmerHomeSkeleton();
          }
          if (state is TeacherHomeError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context.read<TeacherHomeCubit>().load(),
            );
          }
          if (state is TeacherHomeLoaded) {
            return _HomeContent(data: state.data);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final TeacherHomeData data;
  const _HomeContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => context.read<TeacherHomeCubit>().refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WelcomeCard(data: data),
            const SizedBox(height: 16),
            _StatsRow(stats: data.stats),
            const SizedBox(height: 16),
            _TripsBanner(onTap: () => context.push('/teacher-trips')),
            const SizedBox(height: 22),
            SectionHeader(
              title: 'الإعلانات',
              actionLabel: 'عرض الكل',
              onAction: () => context.push('/teacher-announcements'),
            ),
            const SizedBox(height: 12),
            if (data.banners.isNotEmpty)
              _BannerCarousel(banners: data.banners)
            else
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: EmptyStateWidget(
                  message: 'لا توجد إعلانات حالياً',
                  icon: Icons.campaign_outlined,
                ),
              ),
            const SizedBox(height: 22),
            const SectionHeader(title: 'جداول الصفوف'),
            const SizedBox(height: 12),
            _ClassSchedulesSection(classes: data.classes),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final TeacherHomeData data;
  const _WelcomeCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE، d MMMM yyyy', 'ar').format(DateTime.now());
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحباً،',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                Text(
                  data.teacherName,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        today,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _TeacherAvatar(avatar: data.teacherAvatar, name: data.teacherName),
        ],
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
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.accent, width: 2.5),
      ),
      child: ClipOval(
        child: avatar != null && avatar!.isNotEmpty
            ? Image.network(
                avatar!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _InitialsAvatar(name: name),
              )
            : _InitialsAvatar(name: name),
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String name;
  const _InitialsAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0] : 'م';
    return Container(
      color: AppColors.accent.withOpacity(0.3),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final TeacherStats stats;
  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              label: 'صفوفي',
              value: '${stats.classesCount}',
              icon: Icons.class_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatCard(
              label: 'طلابي',
              value: '${stats.totalStudents}',
              icon: Icons.people_rounded,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatCard(
              label: 'حصص اليوم',
              value: '${stats.todayPeriods}',
              icon: Icons.schedule_rounded,
              color: AppColors.present,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatCard(
              label: 'غياب معلق',
              value: '${stats.pendingAttendance}',
              icon: Icons.pending_actions_rounded,
              color: AppColors.absent,
            ),
          ),
        ],
      ),
    );
  }
}

class _TripsBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _TripsBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.present.withOpacity(0.15), AppColors.present.withOpacity(0.05)],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.present.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: AppColors.present.withOpacity(0.2), shape: BoxShape.circle),
              child: const Icon(Icons.directions_bus_rounded, color: AppColors.present, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('جولاتي', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  Text('تتبع جولة الباص المباشر', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.arrow_back_ios_rounded, size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _BannerCarousel extends StatefulWidget {
  final List<home_data.Banner> banners;
  const _BannerCarousel({required this.banners});

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  late final PageController _pageController;
  int _currentIndex = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.banners.length > 1) {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_currentIndex + 1) % widget.banners.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.banners.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return GestureDetector(
                onTap: banner.link != null
                    ? () => context.push(banner.link!)
                    : null,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.divider,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: banner.image.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: banner.image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => Container(
                            color: AppColors.divider,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.divider,
                            child: const Icon(Icons.image_not_supported_outlined,
                                color: AppColors.textSecondary, size: 40),
                          ),
                        )
                      : Container(
                          color: AppColors.primary.withOpacity(0.1),
                          child: const Icon(Icons.image_outlined,
                              color: AppColors.textSecondary, size: 40),
                        ),
                ),
              );
            },
          ),
        ),
        if (widget.banners.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.banners.length, (index) {
              final isActive = index == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.accent : AppColors.divider,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _ClassSchedulesSection extends StatelessWidget {
  final List<SchoolClass> classes;
  const _ClassSchedulesSection({required this.classes});

  @override
  Widget build(BuildContext context) {
    if (classes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: EmptyStateWidget(
          message: 'لا توجد صفوف بعد',
          icon: Icons.class_outlined,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: classes
            .map((cls) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ClassScheduleCard(schoolClass: cls),
                ))
            .toList(),
      ),
    );
  }
}

class _ClassScheduleCard extends StatelessWidget {
  final SchoolClass schoolClass;
  const _ClassScheduleCard({required this.schoolClass});

  @override
  Widget build(BuildContext context) {
    final imageUrl = schoolClass.scheduleImage;
    final heroTag = 'teacher-class-schedule-${schoolClass.id}';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    schoolClass.name,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                if (schoolClass.subject.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    schoolClass.subject,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (imageUrl == null || imageUrl.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 16),
              child: Text(
                'لم يتم رفع جدول هذا الصف بعد',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.5,
                  color: AppColors.textSecondary.withOpacity(0.8),
                ),
              ),
            )
          else
            GestureDetector(
              onTap: () => FullscreenImageViewer.open(
                context,
                imageUrl,
                heroTag: heroTag,
                title: schoolClass.name,
              ),
              child: Hero(
                tag: heroTag,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 160,
                    color: AppColors.divider,
                    child: const Center(
                      child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 160,
                    color: AppColors.divider,
                    child: const Icon(Icons.image_not_supported_outlined,
                        color: AppColors.textSecondary, size: 36),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
