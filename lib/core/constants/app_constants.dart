class AppConstants {
  AppConstants._();

  static const String appName = 'مدارس نور الأردن الدولية';
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String userTypeKey = 'user_type';
  static const String userTypeStudent = 'student';
  static const String userTypeTeacher = 'teacher';
  static const String cachedHomeKey = 'cached_home';
  static const String cachedScheduleKey = 'cached_schedule';
  static const String cachedGradesKey = 'cached_grades';
  static const String lastUpdateKey = 'last_update';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const int pageSize = 15;
}
