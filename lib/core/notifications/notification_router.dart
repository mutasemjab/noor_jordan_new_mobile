import 'package:flutter/widgets.dart';

import '../../features/chat/domain/entities/chat_contact.dart';
import '../../features/subjects/domain/entities/subject.dart';
import '../constants/app_constants.dart';
import '../di/injection.dart';
import '../router/app_router.dart';
import '../storage/local_storage.dart';

/// Opens the page a notification belongs to.
///
/// Used for every way a notification can be tapped:
///  * FCM push tapped while the app is in the background (onMessageOpenedApp)
///  * FCM push tapped while the app was fully closed (getInitialMessage)
///  * local notification shown while the app was open (foreground)
///  * an item tapped in the in-app notifications list
///
/// On a cold start the tap arrives before the splash screen has decided where
/// to go, and the splash's `context.go(...)` would wipe out anything pushed
/// earlier. So a tap is held as "pending" until the student/teacher home
/// shell is on screen ([markReady]) and only then opened on top of it.
///
/// The `type` values must match what the backend sends
/// (StudentContentObserver, StudentRecordObserver, AnnouncementController,
/// Chat NotifyController / Teacher ChatController, Teacher TripController).
class NotificationRouter {
  NotificationRouter._();

  static Map<String, dynamic>? _pending;
  static bool _ready = false;

  /// Entry point for a tapped push / local notification.
  static void handleTap(Map<String, dynamic> data) {
    if (data.isEmpty) return;
    if (_ready) {
      open(data);
    } else {
      _pending = Map<String, dynamic>.from(data);
    }
  }

  /// Called once the logged-in home shell (student or teacher) is mounted.
  static void markReady() {
    _ready = true;
    final pending = _pending;
    _pending = null;
    if (pending != null) {
      // Wait for the home route's frame so the push lands on top of it.
      WidgetsBinding.instance.addPostFrameCallback((_) => open(pending));
    }
  }

  /// Types that have their own page (anything else stays in the list).
  static const _typesWithPage = {
    'announcement', 'announcements', 'exam_schedule', 'previous_year_exam',
    'question_bank', 'worksheet', 'exam', 'external_link', 'video', 'grade',
    'attendance', 'chat', 'bus_tracking', 'bus_approaching',
  };

  /// Tap on an item in the in-app notifications list.
  static void openFromList(String type, Map<String, dynamic>? data) {
    if (!_typesWithPage.contains(type)) return; // e.g. "general" — already in the list
    open({...?data, 'type': type});
  }

  /// Opens the page for [data] (`type` or `screen`, plus optional ids).
  static Future<void> open(Map<String, dynamic> data) async {
    try {
      final storage = sl<LocalStorage>();
      final token = await storage.getToken();
      if (token == null || token.isEmpty) {
        // Logged out — keep it until someone logs in and reaches home.
        _ready = false;
        _pending = Map<String, dynamic>.from(data);
        return;
      }

      final isTeacher =
          storage.getUserType() == AppConstants.userTypeTeacher;
      final type = _str(data['type']) ?? _str(data['screen']) ?? '';

      if (isTeacher) {
        _openForTeacher(type, data);
      } else {
        _openForStudent(type, data);
      }
    } catch (e) {
      debugPrint('NotificationRouter: failed to open $data: $e');
    }
  }

  static void _openForStudent(String type, Map<String, dynamic> data) {
    switch (type) {
      case 'announcement':
      case 'announcements':
        final id = _int(data['id']);
        if (id != null) {
          appRouter.push('/announcements/$id');
        } else {
          appRouter.go('/announcements');
        }
        break;
      case 'exam_schedule':
        appRouter.push('/exam-schedules');
        break;
      case 'previous_year_exam':
        appRouter.push('/files?tab=0');
        break;
      case 'question_bank':
        appRouter.push('/files?tab=1');
        break;
      case 'worksheet':
        appRouter.push('/files?tab=2');
        break;
      case 'exam':
        appRouter.push('/exams');
        break;
      case 'external_link':
        appRouter.push('/external-links');
        break;
      case 'video':
        final subjectId = _int(data['subject_id']);
        if (subjectId != null) {
          appRouter.push(
            '/subjects/$subjectId/videos',
            extra: Subject(
              id: subjectId,
              nameAr: _str(data['subject_name']) ?? 'الفيديوهات',
            ),
          );
        } else {
          appRouter.push('/subjects');
        }
        break;
      case 'grade':
        appRouter.push('/grades');
        break;
      case 'attendance':
        appRouter.push('/attendance');
        break;
      case 'chat':
        if (!_openChat(data)) appRouter.push('/messages');
        break;
      case 'bus_tracking':
      case 'bus_approaching':
        appRouter.push('/bus-tracking');
        break;
      case 'general':
      case 'home':
        // Admin's free-text notifications: show them in the list.
        appRouter.push('/notifications');
        break;
      default:
        appRouter.push('/notifications');
        break;
    }
  }

  static void _openForTeacher(String type, Map<String, dynamic> data) {
    switch (type) {
      case 'chat':
        if (!_openChat(data)) appRouter.push('/teacher-messages');
        break;
      case 'announcement':
      case 'announcements':
        appRouter.push('/teacher-announcements');
        break;
      default:
        // Student-only pages don't exist for teachers; stay on home.
        break;
    }
  }

  /// Opens the conversation with the sender. Returns false if the payload
  /// doesn't identify the sender (e.g. a push from an older backend).
  static bool _openChat(Map<String, dynamic> data) {
    final uid = _str(data['sender_uid']);
    if (uid == null) return false;

    final id = _int(data['sender_id']) ?? int.tryParse(uid.split('_').last);
    if (id == null) return false;

    appRouter.push(
      '/chat',
      extra: ChatContact(
        id: id,
        uid: uid,
        name: _str(data['sender_name']) ?? '',
        avatar: _str(data['sender_avatar']),
      ),
    );
    return true;
  }

  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static int? _int(dynamic v) {
    if (v is int) return v;
    if (v == null) return null;
    return int.tryParse(v.toString());
  }
}
