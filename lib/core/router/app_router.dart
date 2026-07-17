import 'package:flutter/material.dart';
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

// Teacher shell + pages
import '../../features/teacher_home/presentation/pages/teacher_home_page.dart';
import '../../features/teacher_schedule/presentation/pages/teacher_schedule_page.dart';
import '../../features/classes/presentation/pages/classes_page.dart';
import '../../features/teacher_attendance/presentation/pages/teacher_attendance_page.dart';
import '../../features/teacher_grades/presentation/pages/teacher_grades_page.dart';
import '../../features/teacher_profile/presentation/pages/teacher_profile_page.dart';
import '../../features/subjects/domain/entities/subject.dart';
import '../../features/subjects/domain/entities/subject_video.dart';
import '../../features/exams/domain/entities/exam.dart';

import '../constants/app_colors.dart';

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
          path: '/schedule',
          pageBuilder: (_, state) => _fadePage(state, const SchedulePage()),
        ),
        GoRoute(
          path: '/grades',
          pageBuilder: (_, state) => _fadePage(state, const GradesPage()),
        ),
        GoRoute(
          path: '/attendance',
          pageBuilder: (_, state) => _fadePage(state, const AttendancePage()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (_, state) => _fadePage(state, const StudentProfilePage()),
        ),
      ],
    ),

    // ── Student Extra Routes (outside shell, full-screen) ──
    GoRoute(
      path: '/subjects',
      pageBuilder: (_, state) => _slidePage(state, const SubjectsPage()),
    ),
    GoRoute(
      path: '/subjects/:id/videos',
      pageBuilder: (_, state) {
        final subject = state.extra as Subject?;
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
    GoRoute(
      path: '/contract',
      pageBuilder: (_, state) => _slidePage(state, const ContractPage()),
    ),
    GoRoute(
      path: '/announcements',
      pageBuilder: (_, state) => _slidePage(state, const AnnouncementsPage()),
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
      path: '/educational-notes',
      pageBuilder: (_, state) => _slidePage(state, const EducationalNotesPage()),
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
          path: '/teacher-schedule',
          pageBuilder: (_, state) => _fadePage(state, const TeacherSchedulePage()),
        ),
        GoRoute(
          path: '/teacher-classes',
          pageBuilder: (_, state) => _fadePage(state, const ClassesPage()),
        ),
        GoRoute(
          path: '/teacher-attendance',
          pageBuilder: (_, state) => _fadePage(state, const TeacherAttendancePage()),
        ),
        GoRoute(
          path: '/teacher-grades',
          pageBuilder: (_, state) => _fadePage(state, const TeacherGradesPage()),
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
  static const _tabs = ['/home', '/schedule', '/grades', '/attendance', '/profile'];

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
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, -2))],
        ),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: (i) => context.go(_tabs[i]),
          elevation: 0,
          backgroundColor: Colors.transparent,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today_rounded), label: 'الجدول'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart_rounded), label: 'العلامات'),
            BottomNavigationBarItem(icon: Icon(Icons.fact_check_outlined), activeIcon: Icon(Icons.fact_check_rounded), label: 'الحضور'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded), label: 'حسابي'),
          ],
        ),
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
    '/teacher-schedule',
    '/teacher-classes',
    '/teacher-attendance',
    '/teacher-grades',
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
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, -2))],
        ),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: (i) => context.go(_tabs[i]),
          elevation: 0,
          backgroundColor: Colors.transparent,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today_rounded), label: 'جدولي'),
            BottomNavigationBarItem(icon: Icon(Icons.class_outlined), activeIcon: Icon(Icons.class_rounded), label: 'صفوفي'),
            BottomNavigationBarItem(icon: Icon(Icons.fact_check_outlined), activeIcon: Icon(Icons.fact_check_rounded), label: 'الغياب'),
            BottomNavigationBarItem(icon: Icon(Icons.grading_outlined), activeIcon: Icon(Icons.grading_rounded), label: 'العلامات'),
          ],
        ),
      ),
    );
  }
}
