import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static String formatArabicDate(DateTime date) {
    return DateFormat('EEEE، d MMMM yyyy', 'ar').format(date);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('d/M/yyyy', 'ar').format(date);
  }

  static String formatTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length < 2) return time;
      final hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour < 12 ? 'ص' : 'م';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      return '$displayHour:$minute $period';
    } catch (_) {
      return time;
    }
  }

  static String getDayName(int weekday) {
    const days = ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
    return days[(weekday - 1) % 7];
  }

  static String getArabicWeekDay(String day) {
    const map = {
      'sunday': 'الأحد',
      'monday': 'الاثنين',
      'tuesday': 'الثلاثاء',
      'wednesday': 'الأربعاء',
      'thursday': 'الخميس',
      'friday': 'الجمعة',
      'saturday': 'السبت',
    };
    return map[day.toLowerCase()] ?? day;
  }

  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inDays > 365) {
      return 'منذ ${(diff.inDays / 365).floor()} سنة';
    } else if (diff.inDays > 30) {
      return 'منذ ${(diff.inDays / 30).floor()} شهر';
    } else if (diff.inDays > 0) {
      return 'منذ ${diff.inDays} يوم';
    } else if (diff.inHours > 0) {
      return 'منذ ${diff.inHours} ساعة';
    } else if (diff.inMinutes > 0) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  static String formatLastUpdate(String? isoString) {
    if (isoString == null) return '';
    try {
      final dt = DateTime.parse(isoString);
      return 'آخر تحديث: ${formatTime('${dt.hour}:${dt.minute.toString().padLeft(2, '0')}')}';
    } catch (_) {
      return '';
    }
  }
}
