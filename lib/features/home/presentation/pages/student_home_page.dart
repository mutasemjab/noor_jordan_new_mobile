import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../chat/domain/entities/chat_contact.dart';
import '../../../chat/presentation/cubit/teacher_contacts_cubit.dart';
import '../../../chat/presentation/cubit/teacher_contacts_state.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../../../student_trip/presentation/cubit/student_trip_cubit.dart';
import '../../../student_trip/presentation/cubit/student_trip_state.dart';
import '../../../subjects/domain/entities/subject.dart';
import '../../../subjects/presentation/cubit/subjects_cubit.dart';
import '../../../subjects/presentation/cubit/subjects_state.dart';
import '../../domain/entities/home_data.dart' hide Banner;
import '../../domain/entities/home_data.dart' as home_data show Banner;
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';

class StudentHomePage extends StatelessWidget {
  const StudentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<HomeCubit>()..load()),
        BlocProvider(create: (_) => sl<TeacherContactsCubit>()..load()),
        BlocProvider(create: (_) => sl<SubjectsCubit>()..loadSubjects()),
        BlocProvider(create: (_) => sl<AuthCubit>()),
        BlocProvider(create: (_) => sl<StudentTripCubit>()..load()),
      ],
      child: const _StudentHomeView(),
    );
  }
}

class _StudentHomeView extends StatefulWidget {
  const _StudentHomeView();

  @override
  State<_StudentHomeView> createState() => _StudentHomeViewState();
}

class _StudentHomeViewState extends State<_StudentHomeView> {
  late final NetworkInfo _networkInfo;
  StreamSubscription<bool>? _connectivitySubscription;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _networkInfo = sl<NetworkInfo>();
    _networkInfo.isConnected.then((connected) {
      if (mounted) setState(() => _isOffline = !connected);
    });
    _connectivitySubscription =
        _networkInfo.connectivityStream.listen((connected) {
      if (mounted) setState(() => _isOffline = !connected);
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is StudentAuthenticated) {
          // A sibling switch swapped the token/user data in local storage —
          // reload everything on this page so it reflects the new identity.
          context.read<HomeCubit>().load();
          context.read<TeacherContactsCubit>().load();
          context.read<SubjectsCubit>().loadSubjects();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم التبديل إلى ${state.student.name}', style: const TextStyle(fontFamily: 'Cairo')),
              backgroundColor: AppColors.present,
            ),
          );
        }
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.error),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            if (_isOffline) _buildOfflineBanner(),
            Expanded(
              child: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading) {
                    return const ShimmerHomeSkeleton();
                  }
                  if (state is HomeError) {
                    return AppErrorWidget(
                      message: state.message,
                      onRetry: () => context.read<HomeCubit>().load(),
                    );
                  }
                  if (state is HomeLoaded) {
                    return _buildContent(context, state);
                  }
                  return const ShimmerHomeSkeleton();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const Text(
        AppConstants.appName,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: Colors.white,
        ),
      ),
      actions: [
        BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            final count = state is HomeLoaded
                ? state.data.stats.notificationsCount
                : 0;
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined,
                      color: Colors.white),
                  onPressed: () => context.push('/notifications'),
                ),
                if (count > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      constraints:
                          const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        count > 99 ? '99+' : '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Cairo',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        GestureDetector(
          onTap: () => context.go('/profile'),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: _buildProfileAvatar(context),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileAvatar(BuildContext context) {
    final localStorage = sl<LocalStorage>();
    final userData = localStorage.getUserData();
    final avatar = userData?['avatar'] as String?;
    final name = userData?['name'] as String? ?? '';

    if (avatar != null && avatar.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: CachedNetworkImageProvider(avatar),
        backgroundColor: AppColors.primaryLight,
      );
    }
    return CircleAvatar(
      radius: 18,
      backgroundColor: AppColors.accent,
      child: Text(
        name.isNotEmpty ? name[0] : 'ط',
        style: const TextStyle(
          fontFamily: 'Cairo',
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      color: AppColors.error,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Text(
            'لا يوجد اتصال بالإنترنت - يتم عرض البيانات المحفوظة',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, HomeLoaded state) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => context.read<HomeCubit>().refresh(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildSiblingSelector(context)),
          SliverToBoxAdapter(child: _buildWelcomeCard(context)),
          SliverToBoxAdapter(child: const SizedBox(height: 16)),
          SliverToBoxAdapter(child: _buildStatsRow(context, state.data.stats)),
          SliverToBoxAdapter(child: _buildBusTripBanner(context)),
          SliverToBoxAdapter(child: const SizedBox(height: 22)),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'إعلانات اليوم',
              onAction: () => context.go('/announcements'),
            ),
          ),
          SliverToBoxAdapter(child: const SizedBox(height: 12)),
          if (state.data.banners.isNotEmpty)
            SliverToBoxAdapter(
                child: _BannerCarousel(banners: state.data.banners))
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: EmptyStateWidget(
                  message: 'لا توجد إعلانات حالياً',
                  icon: Icons.campaign_outlined,
                ),
              ),
            ),
          SliverToBoxAdapter(child: const SizedBox(height: 22)),
          SliverToBoxAdapter(child: _buildMyTeachersSection(context)),
          SliverToBoxAdapter(child: _buildMySubjectsSection(context)),
          SliverToBoxAdapter(child: const SizedBox(height: 15)),
        ],
      ),
    );
  }

  Widget _buildMyTeachersSection(BuildContext context) {
    return BlocBuilder<TeacherContactsCubit, TeacherContactsState>(
      builder: (context, state) {
        if (state is! TeacherContactsLoaded || state.teachers.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'معلميّ',
              actionLabel: 'عرض الكل',
              onAction: () => context.push('/student-teachers'),
            ),
            const SizedBox(height: 12),
            _MyTeachersList(teachers: state.teachers),
            const SizedBox(height: 22),
          ],
        );
      },
    );
  }

  Widget _buildMySubjectsSection(BuildContext context) {
    return BlocBuilder<SubjectsCubit, SubjectsState>(
      builder: (context, state) {
        if (state is! SubjectsLoaded || state.subjects.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'موادي',
              actionLabel: 'عرض الكل',
              onAction: () => context.push('/subjects'),
            ),
            const SizedBox(height: 12),
            _MySubjectsList(subjects: state.subjects),
            const SizedBox(height: 22),
          ],
        );
      },
    );
  }

  Widget _buildBusTripBanner(BuildContext context) {
    return BlocBuilder<StudentTripCubit, StudentTripState>(
      builder: (context, state) {
        if (state is! StudentTripLoaded || state.trip == null) return const SizedBox.shrink();
        final trip = state.trip!;
        final arrived = trip.arrivedAtMe != null;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: GestureDetector(
            onTap: () => context.push('/bus-tracking'),
            child: Container(
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
                    child: Icon(arrived ? Icons.check_circle_rounded : Icons.directions_bus_rounded, color: AppColors.present, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(arrived ? 'الباص وصل عندك' : 'الباص جاي', style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        Text(
                          arrived ? 'اضغط لتفاصيل الجولة' : (trip.myEtaMinutes != null ? 'يصلك خلال ${trip.myEtaMinutes} دقيقة تقريباً' : 'اضغط لمتابعة الجولة الحية'),
                          style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_back_ios_rounded, size: 16, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSiblingSelector(BuildContext context) {
    final localStorage = sl<LocalStorage>();
    final userData = localStorage.getUserData();
    final siblingsRaw = userData?['siblings'] as List<dynamic>?;

    // The backend's `siblings` list holds only the *other* sibling accounts
    // (it excludes the one currently logged in), so a single entry already
    // means there's someone to switch to.
    if (siblingsRaw == null || siblingsRaw.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentId = userData?['id'];
    final currentName = userData?['name'] as String? ?? 'الطالب';

    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: GestureDetector(
        onTap: () => _showSiblingsSheet(context, siblingsRaw, currentId),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.accent.withOpacity(0.25),
                child: Text(
                  currentName.isNotEmpty ? currentName[0] : 'ط',
                  style: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('الحساب النشط', style: TextStyle(fontFamily: 'Cairo', color: Colors.white60, fontSize: 10)),
                    Text(
                      currentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.unfold_more_rounded, color: Colors.white70, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showSiblingsSheet(BuildContext context, List<dynamic> siblingsRaw, dynamic currentId) {
    final authCubit = context.read<AuthCubit>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const Text(
              'التبديل بين الحسابات',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            ...siblingsRaw.map((s) {
              final sibling = s as Map<String, dynamic>;
              final id = sibling['id'] as int?;
              final name = sibling['name'] as String? ?? '';
              final className = sibling['class'] as String? ?? sibling['class_name'] as String? ?? '';
              final isActive = id == currentId;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: isActive ? AppColors.accent.withOpacity(0.15) : AppColors.primary.withOpacity(0.08),
                  child: Text(
                    name.isNotEmpty ? name[0] : 'ط',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w700,
                      color: isActive ? AppColors.accentDark : AppColors.primary,
                    ),
                  ),
                ),
                title: Text(name,
                    style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
                subtitle: className.isNotEmpty
                    ? Text(className, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary))
                    : null,
                trailing: isActive
                    ? const Icon(Icons.check_circle_rounded, color: AppColors.accent)
                    : const Icon(Icons.chevron_left_rounded, color: AppColors.textSecondary),
                onTap: (isActive || id == null)
                    ? () => Navigator.pop(sheetContext)
                    : () {
                        Navigator.pop(sheetContext);
                        authCubit.switchSibling(id);
                      },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    final localStorage = sl<LocalStorage>();
    final userData = localStorage.getUserData();
    final name = userData?['name'] as String? ?? 'الطالب';
    final className = userData?['class_name'] as String? ?? '';
    final now = DateTime.now();
    final arabicDate = _formatArabicDate(now);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
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
                const Text(
                  'أهلاً وسهلاً،',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (className.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.accent.withOpacity(0.4)),
                    ),
                    child: Text(
                      className,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: Colors.white54, size: 13),
                    const SizedBox(width: 5),
                    Text(
                      arabicDate,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school_outlined,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, HomeStats stats) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              label: 'نسبة الحضور',
              value: '${stats.attendancePercent.toStringAsFixed(1)}%',
              icon: Icons.how_to_reg_outlined,
              color: AppColors.present,
              onTap: () => context.push('/attendance'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatCard(
              label: 'متوسط الدرجات',
              value: '-',
              icon: Icons.grade_outlined,
              color: AppColors.accent,
              onTap: () => context.push('/grades'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatCard(
              label: 'حصص اليوم',
              value: '${stats.todayPeriods}',
              icon: Icons.access_time_outlined,
              color: AppColors.primary,
              onTap: () => context.push('/schedule'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatCard(
              label: 'الإشعارات',
              value: '${stats.notificationsCount}',
              icon: Icons.notifications_outlined,
              color: AppColors.error,
              onTap: () => context.push('/notifications'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatArabicDate(DateTime date) {
    const arabicMonths = [
      'يناير', 'فبراير', 'مارس', 'إبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    const arabicDays = [
      'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس',
      'الجمعة', 'السبت', 'الأحد',
    ];
    final dayName = arabicDays[date.weekday - 1];
    final monthName = arabicMonths[date.month - 1];
    return '$dayName، ${date.day} $monthName ${date.year}';
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

class _MyTeachersList extends StatelessWidget {
  final List<ChatContact> teachers;
  const _MyTeachersList({required this.teachers});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: teachers.length,
        itemBuilder: (context, index) {
          final teacher = teachers[index];
          return GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ChatPage(contact: teacher)),
            ),
            child: Container(
              width: 90,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.divider, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: teacher.avatar != null && teacher.avatar!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: teacher.avatar!,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: AppColors.primary.withOpacity(0.1),
                                child: const Icon(Icons.person,
                                    color: AppColors.primary, size: 28),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: AppColors.primary.withOpacity(0.1),
                                child: const Icon(Icons.person,
                                    color: AppColors.primary, size: 28),
                              ),
                            )
                          : Container(
                              color: AppColors.primary.withOpacity(0.1),
                              child: Center(
                                child: Text(
                                  teacher.name.isNotEmpty ? teacher.name[0] : 'م',
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    teacher.name.split(' ').take(2).join(' '),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MySubjectsList extends StatelessWidget {
  final List<Subject> subjects;
  const _MySubjectsList({required this.subjects});

  static const _palette = [
    Color(0xFF233a77),
    Color(0xFF1565C0),
    Color(0xFF6A1B9A),
    Color(0xFF00695C),
    Color(0xFF558B2F),
    Color(0xFFE65100),
  ];

  Color _colorFor(Subject subject, int index) {
    if (subject.colorClass != null && subject.colorClass!.isNotEmpty) {
      try {
        final hex = subject.colorClass!.replaceAll('#', '');
        return Color(int.parse('FF$hex', radix: 16));
      } catch (_) {}
    }
    return _palette[index % _palette.length];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];
          final color = _colorFor(subject, index);
          return GestureDetector(
            onTap: () => context.push('/subjects/${subject.id}/videos', extra: subject),
            child: Container(
              width: 130,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: -14,
                    bottom: -14,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), shape: BoxShape.circle),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 18),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject.nameAr,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          if (subject.teacherName != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subject.teacherName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 10,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
