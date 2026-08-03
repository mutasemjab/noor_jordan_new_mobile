class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://noor-jordan.com/api';

  // Student Auth
  static const String studentLogin = '/v1/student/auth/login';
  static const String studentLogout = '/v1/student/auth/logout';
  static const String studentDeleteAccount = '/v1/student/auth/delete-account';
  static String studentSwitchSibling(int siblingId) => '/v1/student/auth/switch-sibling/$siblingId';

  // Student Data
  static const String studentHome = '/v1/student/home';
  static const String studentProfile = '/v1/student/profile';
  static const String studentSchedule = '/v1/student/my-schedule';
  static const String studentExamSchedules = '/v1/student/exam-schedules';
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
  static const String studentFirebaseToken = '/v1/student/firebase-token';

  // Teacher Auth
  static const String teacherLogin = '/v1/teacher/auth/login';
  static const String teacherLogout = '/v1/teacher/auth/logout';

  // Teacher Data
  static const String teacherHome = '/v1/teacher/home';
  static const String teacherProfile = '/v1/teacher/profile';
  static const String teacherUpdateProfile = '/v1/teacher/profile/update';
  static const String teacherClasses = '/v1/teacher/my-classes';
  static String teacherClassStudents(int classId) => '/v1/teacher/classes/$classId/students';
  static String teacherClassSubjects(int classId) => '/v1/teacher/classes/$classId/subjects';

  // Teacher Attendance
  static const String teacherAttendance = '/v1/teacher/attendance';
  static const String teacherAttendanceClasses = '/v1/teacher/attendance/classes';
  static const String teacherSubmitAttendance = '/v1/teacher/attendance/submit';

  // Teacher Grades — single endpoint for both listing (GET) and
  // recording/updating (POST) grades, scoped by class_id + subject_id.
  static const String teacherGrades = '/v1/teacher/grades';

  static const String teacherAnnouncements = '/v1/teacher/announcements';
  static String teacherAnnouncementDetail(int id) => '/v1/teacher/announcements/$id';
  static const String teacherBanners = '/v1/student/banners';
  static const String teacherDeviceToken = '/v1/teacher/device-token';
  static const String teacherFirebaseToken = '/v1/teacher/firebase-token';

  // Teacher Educational Notes (مفكرتي)
  static String teacherClassNotes(int classId) => '/v1/teacher/classes/$classId/educational-notes';
  static const String teacherCreateNote = '/v1/teacher/educational-notes';
  static String teacherUpdateNote(int id) => '/v1/teacher/educational-notes/$id';
  static String teacherDeleteNote(int id) => '/v1/teacher/educational-notes/$id';

  // Teacher Files (question banks / previous-year exams / worksheets)
  static const String teacherQuestionBanks = '/v1/teacher/question-banks';
  static String teacherQuestionBankDetail(int id) => '/v1/teacher/question-banks/$id';
  static const String teacherPreviousYearExams = '/v1/teacher/previous-year-exams';
  static String teacherPreviousYearExamDetail(int id) => '/v1/teacher/previous-year-exams/$id';
  static const String teacherWorksheets = '/v1/teacher/worksheets';
  static String teacherWorksheetDetail(int id) => '/v1/teacher/worksheets/$id';

  // Teacher Videos (YouTube)
  static String teacherClassVideos(int classId) => '/v1/teacher/classes/$classId/videos';
  static String teacherDeleteVideo(int classId, int videoId) => '/v1/teacher/classes/$classId/videos/$videoId';

  // Teacher Exams (creation/management)
  static const String teacherExams = '/v1/teacher/exams';
  static String teacherExamDetail(int id) => '/v1/teacher/exams/$id';
  static String teacherExamQuestions(int examId) => '/v1/teacher/exams/$examId/questions';
  static String teacherExamQuestionDetail(int examId, int questionId) =>
      '/v1/teacher/exams/$examId/questions/$questionId';

  // Bus Trip Tracking
  static const String teacherMyTrips = '/v1/teacher/my-trips';
  static String teacherStartTrip(int tripId) => '/v1/teacher/trips/$tripId/start';
  static String teacherTripLocation(int tripId) => '/v1/teacher/trips/$tripId/location';
  static String teacherTripStudentArrived(int tripId, int studentId) =>
      '/v1/teacher/trips/$tripId/students/$studentId/arrived';
  static String teacherCompleteTrip(int tripId) => '/v1/teacher/trips/$tripId/complete';
  static const String studentMyTrip = '/v1/student/my-trip';

  // Chat (Student + Teacher)
  static const String chatMedia = '/v1/chat/media';
  static const String chatNotify = '/v1/chat/notify';
  static const String teacherChatBroadcast = '/v1/teacher/chat/broadcast';
}
