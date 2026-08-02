import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/role_select_page.dart';
import '../../features/auth/presentation/pages/student_login_page.dart';
import '../../features/auth/presentation/pages/teacher_login_page.dart';

// Student shell + pages
import '../../features/home/presentation/pages/student_home_page.dart';
import '../../features/schedule/presentation/pages/schedule_page.dart';
import '../../features/grades/presentation/pages/grades_page.dart';
import '../../features/attendance/presentation/pages/attendance_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

// Student extra pages
import '../../features/subjects/presentation/pages/subjects_page.dart';
import '../../features/subjects/presentation/pages/subject_videos_page.dart';
import '../../features/subjects/presentation/pages/video_player_page.dart';
import '../../features/exams/presentation/pages/exams_page.dart';
import '../../features/exams/presentation/pages/exam_detail_page.dart';
import '../../features/exams/presentation/pages/exam_taking_page.dart';
import '../../features/exams/presentation/pages/exam_result_page.dart';
import '../../features/contract/presentation/pages/contract_page.dart';
import '../../features/announcements/presentation/pages/announcements_page.dart';
import '../../features/announcements/presentation/pages/announcement_detail_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/files/presentation/pages/files_page.dart';
import '../../features/educational_notes/presentation/pages/educational_notes_page.dart';
import '../../features/exam_schedules/presentation/pages/exam_schedules_page.dart';
import '../../features/chat/presentation/pages/conversations_list_page.dart';
import '../../features/chat/presentation/pages/student_teacher_list_page.dart';
import '../../features/chat/presentation/pages/teacher_chat_contacts_page.dart';

// Teacher shell + pages
import '../../features/teacher_home/presentation/pages/teacher_home_page.dart';
import '../../features/classes/presentation/pages/classes_page.dart';
import '../../features/teacher_profile/presentation/pages/teacher_profile_page.dart';
import '../../features/subjects/domain/entities/subject.dart';
import '../../features/subjects/domain/entities/subject_video.dart';
import '../../features/exams/domain/entities/exam_entities.dart';
import '../../features/exams/presentation/cubit/exams_cubit.dart';
import '../../features/teacher_trips/presentation/pages/teacher_trips_page.dart';
import '../../features/student_trip/presentation/pages/bus_tracking_page.dart';

import '../constants/app_colors.dart';
import '../di/injection.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _studentShellKey = GlobalKey<NavigatorState>();
final _teacherShellKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/splash',
      builder: (_, __) => const SplashPage(),
    ),
    GoRoute(
      path: '/role-select',
      pageBuilder: (_, state) => _slidePage(state, const RoleSelectPage()),
    ),
    GoRoute(
      path: '/student-login',
      pageBuilder: (_, state) => _slidePage(state, const StudentLoginPage()),
    ),
    GoRoute(
      path: '/teacher-login',
      pageBuilder: (_, state) => _slidePage(state, const TeacherLoginPage()),
    ),

    // ── Student Shell ──────────────────────────────
    ShellRoute(
      navigatorKey: _studentShellKey,
      builder: (context, state, child) => StudentScaffold(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (_, state) => _fadePage(state, const StudentHomePage()),
        ),
        GoRoute(
          path: '/educational-notes',
          pageBuilder: (_, state) => _fadePage(state, const EducationalNotesPage()),
        ),
        GoRoute(
          path: '/announcements',
          pageBuilder: (_, state) => _fadePage(state, const AnnouncementsPage()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (_, state) => _fadePage(state, const StudentProfilePage()),
        ),
      ],
    ),

    // ── Student Extra Routes (outside shell, full-screen) ──
    GoRoute(
      path: '/schedule',
      pageBuilder: (_, state) => _slidePage(state, const SchedulePage()),
    ),
    GoRoute(
      path: '/grades',
      pageBuilder: (_, state) => _slidePage(state, const GradesPage()),
    ),
    GoRoute(
      path: '/attendance',
      pageBuilder: (_, state) => _slidePage(state, const AttendancePage()),
    ),
    GoRoute(
      path: '/subjects',
      pageBuilder: (_, state) => _slidePage(state, const SubjectsPage()),
    ),
    GoRoute(
      path: '/subjects/:id/videos',
      pageBuilder: (_, state) {
        final subject = state.extra as Subject;
        return _slidePage(state, SubjectVideosPage(subject: subject));
      },
    ),
    GoRoute(
      path: '/video-player',
      pageBuilder: (_, state) {
        final video = state.extra as SubjectVideo?;
        return _slidePage(state, VideoPlayerPage(video: video!));
      },
    ),
    GoRoute(
      path: '/exams',
      pageBuilder: (_, state) => _slidePage(state, const ExamsPage()),
    ),
    // Exam detail → taking → result all share one ExamsCubit instance so the
    // in-progress attempt (and its state transitions) survives context.go()
    // between these routes, which otherwise unmounts per-route providers.
    ShellRoute(
      builder: (context, state, child) => BlocProvider(
        create: (_) => sl<ExamsCubit>(),
        child: child,
      ),
      routes: [
        GoRoute(
          path: '/exams/:id',
          pageBuilder: (_, state) {
            final exam = state.extra as Exam?;
            return _slidePage(state, ExamDetailPage(exam: exam));
          },
        ),
        GoRoute(
          path: '/exam-taking',
          pageBuilder: (_, state) => _slidePage(state, const ExamTakingPage()),
        ),
        GoRoute(
          path: '/exam-result',
          pageBuilder: (_, state) => _slidePage(state, const ExamResultPage()),
        ),
      ],
    ),
    GoRoute(
      path: '/contract',
      pageBuilder: (_, state) => _slidePage(state, const ContractPage()),
    ),
    GoRoute(
      path: '/announcements/:id',
      pageBuilder: (_, state) => _slidePage(state, AnnouncementDetailPage(id: int.parse(state.pathParameters['id']!))),
    ),
    GoRoute(
      path: '/notifications',
      pageBuilder: (_, state) => _slidePage(state, const NotificationsPage()),
    ),
    GoRoute(
      path: '/files',
      pageBuilder: (_, state) => _slidePage(state, const FilesPage()),
    ),
    GoRoute(
      path: '/exam-schedules',
      pageBuilder: (_, state) => _slidePage(state, const ExamSchedulesPage()),
    ),
    GoRoute(
      path: '/messages',
      pageBuilder: (context, state) => _slidePage(
        state,
        ConversationsListPage(
          onStartNewChat: () => context.push('/student-teachers'),
        ),
      ),
    ),
    GoRoute(
      path: '/student-teachers',
      pageBuilder: (_, state) => _slidePage(state, const StudentTeacherListPage()),
    ),
    GoRoute(
      path: '/bus-tracking',
      pageBuilder: (_, state) => _slidePage(state, const BusTrackingPage()),
    ),

    // ── Teacher Shell ──────────────────────────────
    ShellRoute(
      navigatorKey: _teacherShellKey,
      builder: (context, state, child) => TeacherScaffold(child: child),
      routes: [
        GoRoute(
          path: '/teacher-home',
          pageBuilder: (_, state) => _fadePage(state, const TeacherHomePage()),
        ),
        GoRoute(
          path: '/teacher-classes',
          pageBuilder: (_, state) => _fadePage(state, const ClassesPage()),
        ),
      ],
    ),

    // Teacher extra routes
    GoRoute(
      path: '/teacher-profile',
      pageBuilder: (_, state) => _slidePage(state, const TeacherProfilePage()),
    ),
    GoRoute(
      path: '/teacher-announcements',
      pageBuilder: (_, state) => _slidePage(state, const AnnouncementsPage(isTeacher: true)),
    ),
    GoRoute(
      path: '/teacher-messages',
      pageBuilder: (context, state) => _slidePage(
        state,
        ConversationsListPage(
          isTeacher: true,
          onStartNewChat: () => context.push('/teacher-chat-contacts'),
        ),
      ),
    ),
    GoRoute(
      path: '/teacher-chat-contacts',
      pageBuilder: (_, state) => _slidePage(state, const TeacherChatContactsPage()),
    ),
    GoRoute(
      path: '/teacher-trips',
      pageBuilder: (_, state) => _slidePage(state, const TeacherTripsPage()),
    ),
  ],
);

CustomTransitionPage<T> _slidePage<T>(GoRouterState state, Widget child) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final isRTL = Directionality.of(context) == TextDirection.rtl;
      final begin = isRTL ? const Offset(-1.0, 0) : const Offset(1.0, 0);
      final tween = Tween(begin: begin, end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}

CustomTransitionPage<T> _fadePage<T>(GoRouterState state, Widget child) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (_, animation, __, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

// ── Student Bottom Nav Shell ────────────────────────────────────────────────

class StudentScaffold extends StatefulWidget {
  final Widget child;
  const StudentScaffold({super.key, required this.child});

  @override
  State<StudentScaffold> createState() => _StudentScaffoldState();
}

class _StudentScaffoldState extends State<StudentScaffold> {
  static const _tabs = ['/home', '/educational-notes', '/announcements', '/profile'];

  static const _items = [
    _NavItemData(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'الرئيسية'),
    _NavItemData(icon: Icons.sticky_note_2_outlined, activeIcon: Icons.sticky_note_2_rounded, label: 'مفكرتي'),
    _NavItemData(icon: Icons.campaign_outlined, activeIcon: Icons.campaign_rounded, label: 'الإعلانات'),
    _NavItemData(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'حسابي'),
  ];

  int _currentIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    for (int i = 0; i < _tabs.length; i++) {
      if (loc.startsWith(_tabs[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: _ModernBottomNav(
        items: _items,
        currentIndex: index,
        onTap: (i) => context.go(_tabs[i]),
      ),
    );
  }
}

// ── Teacher Bottom Nav Shell ────────────────────────────────────────────────

class TeacherScaffold extends StatefulWidget {
  final Widget child;
  const TeacherScaffold({super.key, required this.child});

  @override
  State<TeacherScaffold> createState() => _TeacherScaffoldState();
}

class _TeacherScaffoldState extends State<TeacherScaffold> {
  static const _tabs = [
    '/teacher-home',
    '/teacher-classes',
  ];

  static const _items = [
    _NavItemData(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'الرئيسية'),
    _NavItemData(icon: Icons.class_outlined, activeIcon: Icons.class_rounded, label: 'صفوفي'),
  ];

  int _currentIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    for (int i = 0; i < _tabs.length; i++) {
      if (loc.startsWith(_tabs[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: _ModernBottomNav(
        items: _items,
        currentIndex: index,
        onTap: (i) => context.go(_tabs[i]),
      ),
    );
  }
}

// ── Shared modern bottom nav ────────────────────────────────────────────────

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItemData({required this.icon, required this.activeIcon, required this.label});
}

class _ModernBottomNav extends StatelessWidget {
  final List<_NavItemData> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _ModernBottomNav({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.10), blurRadius: 20, offset: const Offset(0, -6)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: List.generate(items.length, (i) {
              final selected = i == currentIndex;
              final item = items[i];
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary.withOpacity(0.10) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          selected ? item.activeIcon : item.icon,
                          color: selected ? AppColors.primary : AppColors.textSecondary,
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 10.5,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            color: selected ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
