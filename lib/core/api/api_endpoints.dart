class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://YOUR_DOMAIN/api';

  // Student Auth
  static const String studentLogin = '/v1/student/auth/login';
  static const String studentLogout = '/v1/student/auth/logout';
  static const String studentDeleteAccount = '/v1/student/auth/delete-account';
  static String studentSwitchSibling(int siblingId) => '/v1/student/auth/switch-sibling/$siblingId';

  // Student Data
  static const String studentHome = '/v1/student/home';
  static const String studentProfile = '/v1/student/profile';
  static const String studentSchedule = '/v1/student/my-schedule';
  static const String studentAttendance = '/v1/student/my-attendance';
  static const String studentGrades = '/v1/student/my-grades';
  static const String studentSubjects = '/v1/student/my-subjects';
  static String studentSubjectVideos(int subjectId) => '/v1/student/subjects/$subjectId/videos';
  static const String studentMyExams = '/v1/student/my-exams';
  static const String studentExams = '/v1/student/exams';
  static String studentExamDetail(int examId) => '/v1/student/exams/$examId';
  static String studentStartExam(int examId) => '/v1/student/exams/$examId/start';
  static String studentSubmitAttempt(int attemptId) => '/v1/student/attempts/$attemptId/submit';
  static String studentAttemptResult(int attemptId) => '/v1/student/attempts/$attemptId';
  static const String studentContract = '/v1/student/contract';
  static const String studentEducationalNotes = '/v1/student/educational-notes';
  static const String studentAnnouncements = '/v1/student/announcements';
  static String studentAnnouncementDetail(int id) => '/v1/student/announcements/$id';
  static const String studentNotifications = '/v1/student/notifications';
  static String studentMarkNotificationRead(int id) => '/v1/student/notifications/$id/read';
  static const String studentMarkAllRead = '/v1/student/notifications/read-all';
  static const String studentDeviceToken = '/v1/student/device-token';
  static const String studentBanners = '/v1/student/banners';
  static const String studentPreviousExams = '/v1/student/previous-year-exams';
  static const String studentQuestionBanks = '/v1/student/question-banks';
  static const String studentWorksheets = '/v1/student/worksheets';
  static const String studentAppSettings = '/v1/student/app-settings';
  static const String studentTeachers = '/v1/student/teachers';
  static String studentTeacherDetail(int id) => '/v1/student/teachers/$id';

  // Teacher Auth
  static const String teacherLogin = '/v1/teacher/auth/login';
  static const String teacherLogout = '/v1/teacher/auth/logout';

  // Teacher Data
  static const String teacherHome = '/v1/teacher/home';
  static const String teacherProfile = '/v1/teacher/profile';
  static const String teacherUpdateProfile = '/v1/teacher/profile/update';
  static const String teacherSchedule = '/v1/teacher/my-schedule';
  static const String teacherClasses = '/v1/teacher/my-classes';
  static String teacherClassStudents(int classId) => '/v1/teacher/classes/$classId/students';

  // Teacher Attendance
  static const String teacherAttendance = '/v1/teacher/attendance';
  static const String teacherAttendanceClasses = '/v1/teacher/attendance/classes';
  static String teacherAttendanceStudents(int classId) => '/v1/teacher/attendance/classes/$classId/students';
  static const String teacherSubmitAttendance = '/v1/teacher/attendance/submit';

  // Teacher Grades
  static const String teacherGrades = '/v1/teacher/grades';
  static const String teacherGradeClasses = '/v1/teacher/grades/classes';
  static String teacherGradeExamTypes(int classId) => '/v1/teacher/grades/classes/$classId/exam-types';
  static String teacherGradeStudents(int classId, int examTypeId) =>
      '/v1/teacher/grades/classes/$classId/exam-types/$examTypeId/students';
  static const String teacherSubmitGrades = '/v1/teacher/grades/submit';

  static const String teacherAnnouncements = '/v1/teacher/announcements';
  static String teacherAnnouncementDetail(int id) => '/v1/teacher/announcements/$id';
  static const String teacherDeviceToken = '/v1/teacher/device-token';
}
