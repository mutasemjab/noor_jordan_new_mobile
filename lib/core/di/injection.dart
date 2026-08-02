import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_client.dart';
import '../network/network_info.dart';
import '../storage/local_storage.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_student_usecase.dart';
import '../../features/auth/domain/usecases/login_teacher_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';

import '../../features/home/data/datasources/home_remote_datasource.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_student_home_usecase.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';

import '../../features/schedule/data/datasources/schedule_remote_datasource.dart';
import '../../features/schedule/data/repositories/schedule_repository_impl.dart';
import '../../features/schedule/domain/repositories/schedule_repository.dart';
import '../../features/schedule/domain/usecases/get_schedule_usecase.dart';
import '../../features/schedule/presentation/cubit/schedule_cubit.dart';

import '../../features/grades/data/datasources/grades_remote_datasource.dart';
import '../../features/grades/data/repositories/grades_repository_impl.dart';
import '../../features/grades/domain/repositories/grades_repository.dart';
import '../../features/grades/domain/usecases/get_grades_usecase.dart';
import '../../features/grades/presentation/cubit/grades_cubit.dart';

import '../../features/attendance/data/datasources/attendance_remote_datasource.dart';
import '../../features/attendance/data/repositories/attendance_repository_impl.dart';
import '../../features/attendance/domain/repositories/attendance_repository.dart';
import '../../features/attendance/domain/usecases/get_attendance_usecase.dart';
import '../../features/attendance/presentation/cubit/attendance_cubit.dart';

import '../../features/chat/data/datasources/chat_firestore_datasource.dart';
import '../../features/chat/data/datasources/chat_remote_datasource.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/data/services/firebase_chat_auth_bridge.dart';
import '../../features/chat/domain/entities/chat_contact.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/domain/usecases/chat_usecases.dart';
import '../../features/chat/presentation/cubit/broadcast_cubit.dart';
import '../../features/chat/presentation/cubit/chat_cubit.dart';
import '../../features/chat/presentation/cubit/conversations_cubit.dart';
import '../../features/chat/presentation/cubit/teacher_contacts_cubit.dart';

import '../../features/exam_schedules/data/datasources/exam_schedules_remote_datasource.dart';
import '../../features/exam_schedules/data/repositories/exam_schedules_repository_impl.dart';
import '../../features/exam_schedules/domain/repositories/exam_schedules_repository.dart';
import '../../features/exam_schedules/domain/usecases/get_exam_schedules_usecase.dart';
import '../../features/exam_schedules/presentation/cubit/exam_schedules_cubit.dart';

import '../../features/subjects/data/datasources/subjects_remote_datasource.dart';
import '../../features/subjects/data/repositories/subjects_repository_impl.dart';
import '../../features/subjects/domain/repositories/subjects_repository.dart';
import '../../features/subjects/domain/usecases/get_subjects_usecase.dart';
import '../../features/subjects/domain/usecases/get_subject_videos_usecase.dart';
import '../../features/subjects/presentation/cubit/subjects_cubit.dart';

import '../../features/exams/data/datasources/exams_remote_datasource.dart';
import '../../features/exams/data/repositories/exams_repository_impl.dart';
import '../../features/exams/domain/repositories/exams_repository.dart';
import '../../features/exams/domain/usecases/get_exam_detail_usecase.dart';
import '../../features/exams/domain/usecases/get_exams_usecase.dart';
import '../../features/exams/domain/usecases/get_my_exams_usecase.dart';
import '../../features/exams/domain/usecases/start_exam_usecase.dart';
import '../../features/exams/domain/usecases/submit_exam_usecase.dart';
import '../../features/exams/presentation/cubit/exams_cubit.dart';

import '../../features/announcements/data/datasources/announcements_remote_datasource.dart';
import '../../features/announcements/data/repositories/announcements_repository_impl.dart';
import '../../features/announcements/domain/repositories/announcements_repository.dart';
import '../../features/announcements/domain/usecases/get_announcements_usecase.dart';
import '../../features/announcements/presentation/cubit/announcements_cubit.dart';

import '../../features/notifications/data/datasources/notifications_remote_datasource.dart';
import '../../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../features/notifications/domain/usecases/get_notifications_usecase.dart';
import '../../features/notifications/domain/usecases/mark_read_usecase.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';

import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';

import '../../features/contract/data/datasources/contract_remote_datasource.dart';
import '../../features/contract/data/repositories/contract_repository_impl.dart';
import '../../features/contract/domain/repositories/contract_repository.dart';
import '../../features/contract/domain/usecases/get_contract_usecase.dart';
import '../../features/contract/presentation/cubit/contract_cubit.dart';

import '../../features/educational_notes/data/datasources/notes_remote_datasource.dart';
import '../../features/educational_notes/data/repositories/notes_repository_impl.dart';
import '../../features/educational_notes/domain/repositories/notes_repository.dart';
import '../../features/educational_notes/domain/usecases/get_notes_usecase.dart';
import '../../features/educational_notes/presentation/cubit/notes_cubit.dart';

import '../../features/files/data/datasources/files_remote_datasource.dart';
import '../../features/files/data/repositories/files_repository_impl.dart';
import '../../features/files/domain/repositories/files_repository.dart';
import '../../features/files/domain/usecases/get_files_usecase.dart';
import '../../features/files/presentation/cubit/files_cubit.dart';

import '../../features/teacher_home/data/datasources/teacher_home_remote_datasource.dart';
import '../../features/teacher_home/data/repositories/teacher_home_repository_impl.dart';
import '../../features/teacher_home/domain/repositories/teacher_home_repository.dart';
import '../../features/teacher_home/domain/usecases/get_teacher_home_usecase.dart';
import '../../features/teacher_home/presentation/cubit/teacher_home_cubit.dart';

import '../../features/classes/data/datasources/classes_remote_datasource.dart';
import '../../features/classes/data/repositories/classes_repository_impl.dart';
import '../../features/classes/domain/repositories/classes_repository.dart';
import '../../features/classes/domain/usecases/get_classes_usecase.dart';
import '../../features/classes/domain/usecases/get_class_students_usecase.dart';
import '../../features/classes/presentation/cubit/classes_cubit.dart';

import '../../features/teacher_attendance/data/datasources/teacher_attendance_remote_datasource.dart';
import '../../features/teacher_attendance/data/repositories/teacher_attendance_repository_impl.dart';
import '../../features/teacher_attendance/domain/repositories/teacher_attendance_repository.dart';
import '../../features/teacher_attendance/domain/usecases/get_attendance_classes_usecase.dart';
import '../../features/teacher_attendance/domain/usecases/submit_attendance_usecase.dart';
import '../../features/teacher_attendance/presentation/cubit/teacher_attendance_cubit.dart';

import '../../features/teacher_grades/data/datasources/teacher_grades_remote_datasource.dart';
import '../../features/teacher_grades/data/repositories/teacher_grades_repository_impl.dart';
import '../../features/teacher_grades/domain/repositories/teacher_grades_repository.dart';
import '../../features/teacher_grades/domain/usecases/teacher_grades_usecases.dart';
import '../../features/teacher_grades/presentation/cubit/teacher_grades_cubit.dart';

import '../../features/teacher_notes/data/datasources/teacher_notes_remote_datasource.dart';
import '../../features/teacher_notes/data/repositories/teacher_notes_repository_impl.dart';
import '../../features/teacher_notes/domain/repositories/teacher_notes_repository.dart';
import '../../features/teacher_notes/domain/usecases/teacher_notes_usecases.dart';
import '../../features/teacher_notes/presentation/cubit/teacher_notes_cubit.dart';

import '../../features/teacher_profile/data/datasources/teacher_profile_remote_datasource.dart';
import '../../features/teacher_profile/data/repositories/teacher_profile_repository_impl.dart';
import '../../features/teacher_profile/domain/repositories/teacher_profile_repository.dart';
import '../../features/teacher_profile/domain/usecases/get_teacher_profile_usecase.dart';
import '../../features/teacher_profile/domain/usecases/update_teacher_profile_usecase.dart';
import '../../features/teacher_profile/presentation/cubit/teacher_profile_cubit.dart';

import '../../features/teacher_common/data/datasources/teacher_common_remote_datasource.dart';
import '../../features/teacher_common/data/repositories/teacher_common_repository_impl.dart';
import '../../features/teacher_common/domain/repositories/teacher_common_repository.dart';
import '../../features/teacher_common/domain/usecases/get_class_subjects_usecase.dart';

import '../../features/teacher_files/data/datasources/teacher_files_remote_datasource.dart';
import '../../features/teacher_files/data/repositories/teacher_files_repository_impl.dart';
import '../../features/teacher_files/domain/repositories/teacher_files_repository.dart';
import '../../features/teacher_files/domain/usecases/teacher_files_usecases.dart';
import '../../features/teacher_files/presentation/cubit/teacher_files_cubit.dart';

import '../../features/teacher_videos/data/datasources/teacher_videos_remote_datasource.dart';
import '../../features/teacher_videos/data/repositories/teacher_videos_repository_impl.dart';
import '../../features/teacher_videos/domain/repositories/teacher_videos_repository.dart';
import '../../features/teacher_videos/domain/usecases/teacher_videos_usecases.dart';
import '../../features/teacher_videos/presentation/cubit/teacher_videos_cubit.dart';

import '../../features/teacher_exams/data/datasources/teacher_exams_remote_datasource.dart';
import '../../features/teacher_exams/data/repositories/teacher_exams_repository_impl.dart';
import '../../features/teacher_exams/domain/repositories/teacher_exams_repository.dart';
import '../../features/teacher_exams/domain/usecases/teacher_exams_usecases.dart';
import '../../features/teacher_exams/presentation/cubit/teacher_exam_detail_cubit.dart';
import '../../features/teacher_exams/presentation/cubit/teacher_exams_cubit.dart';

import '../../features/teacher_trips/data/datasources/teacher_trips_remote_datasource.dart';
import '../../features/teacher_trips/data/repositories/teacher_trips_repository_impl.dart';
import '../../features/teacher_trips/domain/entities/trip.dart';
import '../../features/teacher_trips/domain/repositories/teacher_trips_repository.dart';
import '../../features/teacher_trips/domain/usecases/teacher_trips_usecases.dart';
import '../../features/teacher_trips/presentation/cubit/teacher_trips_cubit.dart';
import '../../features/teacher_trips/presentation/cubit/trip_execution_cubit.dart';
import '../../features/teacher_trips/services/trip_location_service.dart';

import '../../features/student_trip/data/datasources/student_trip_remote_datasource.dart';
import '../../features/student_trip/data/repositories/student_trip_repository_impl.dart';
import '../../features/student_trip/domain/repositories/student_trip_repository.dart';
import '../../features/student_trip/domain/usecases/get_my_trip_usecase.dart';
import '../../features/student_trip/presentation/cubit/student_trip_cubit.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  // External
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerSingleton<FlutterSecureStorage>(
    const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );
  sl.registerSingleton<Connectivity>(Connectivity());
  try {
    sl.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
    sl.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  } catch (_) {
    // Firebase not configured — chat feature will surface a clear error when opened.
  }

  // Core
  sl.registerSingleton<LocalStorage>(LocalStorage(sl(), sl()));
  sl.registerSingleton<Dio>(ApiClient.getInstance(sl()));
  sl.registerSingleton<NetworkInfo>(NetworkInfoImpl(sl()));

  // Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl(), sl(), sl()));
  sl.registerLazySingleton(() => LoginStudentUseCase(sl()));
  sl.registerLazySingleton(() => LoginTeacherUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerFactory(() => AuthCubit(sl(), sl(), sl(), sl()));

  // Home (Student)
  sl.registerLazySingleton<HomeRemoteDataSource>(() => HomeRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(sl(), sl(), sl()));
  sl.registerLazySingleton(() => GetStudentHomeUseCase(sl()));
  sl.registerFactory(() => HomeCubit(getStudentHome: sl(), localStorage: sl()));

  // Schedule (Student)
  sl.registerLazySingleton<ScheduleRemoteDataSource>(() => ScheduleRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<ScheduleRepository>(() => ScheduleRepositoryImpl(sl(), sl(), sl()));
  sl.registerLazySingleton(() => GetScheduleUseCase(sl()));
  sl.registerFactory(() => ScheduleCubit(getSchedule: sl()));

  // Grades (Student)
  sl.registerLazySingleton<GradesRemoteDataSource>(() => GradesRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<GradesRepository>(() => GradesRepositoryImpl(sl(), sl(), sl()));
  sl.registerLazySingleton(() => GetGradesUseCase(sl()));
  sl.registerFactory(() => GradesCubit(sl()));

  // Attendance (Student)
  sl.registerLazySingleton<AttendanceRemoteDataSource>(() => AttendanceRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<AttendanceRepository>(() => AttendanceRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton(() => GetAttendanceUseCase(sl()));
  sl.registerFactory(() => AttendanceCubit(sl()));

  // Exam Schedules (Student)
  sl.registerLazySingleton<ExamSchedulesRemoteDataSource>(() => ExamSchedulesRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<ExamSchedulesRepository>(() => ExamSchedulesRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton(() => GetExamSchedulesUseCase(sl()));
  sl.registerFactory(() => ExamSchedulesCubit(sl()));

  // Chat
  sl.registerLazySingleton<ChatRemoteDataSource>(() => ChatRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<ChatFirestoreDataSource>(() => ChatFirestoreDataSource(sl()));
  sl.registerLazySingleton<FirebaseChatAuthBridge>(() => FirebaseChatAuthBridge(sl(), sl()));
  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(sl(), sl(), sl(), sl()));
  sl.registerLazySingleton(() => EnsureChatReadyUseCase(sl()));
  sl.registerLazySingleton(() => GetConversationIdUseCase(sl()));
  sl.registerLazySingleton(() => WatchConversationsUseCase(sl()));
  sl.registerLazySingleton(() => WatchMessagesUseCase(sl()));
  sl.registerLazySingleton(() => SendTextMessageUseCase(sl()));
  sl.registerLazySingleton(() => SendMediaMessageUseCase(sl()));
  sl.registerLazySingleton(() => MarkConversationReadUseCase(sl()));
  sl.registerLazySingleton(() => GetMyTeachersUseCase(sl()));
  sl.registerLazySingleton(() => BroadcastToClassUseCase(sl()));
  sl.registerFactory(() => ConversationsCubit(sl(), sl()));
  sl.registerFactory(() => TeacherContactsCubit(sl()));
  sl.registerFactory(() => BroadcastCubit(sl()));
  sl.registerFactoryParam<ChatCubit, ChatContact, void>(
    (contact, _) => ChatCubit(
      contact: contact,
      ensureReady: sl(),
      getConversationId: sl(),
      watchMessages: sl(),
      sendText: sl(),
      sendMedia: sl(),
      markRead: sl(),
    ),
  );

  // Subjects & Videos
  sl.registerLazySingleton<SubjectsRemoteDataSource>(() => SubjectsRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<SubjectsRepository>(() => SubjectsRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton(() => GetSubjectsUseCase(sl()));
  sl.registerLazySingleton(() => GetSubjectVideosUseCase(sl()));
  sl.registerFactory(() => SubjectsCubit(sl(), sl()));

  // Exams
  sl.registerLazySingleton<ExamsRemoteDataSource>(() => ExamsRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<ExamsRepository>(() => ExamsRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton(() => GetExamsUseCase(sl()));
  sl.registerLazySingleton(() => GetMyExamsUseCase(sl()));
  sl.registerLazySingleton(() => GetExamDetailUseCase(sl()));
  sl.registerLazySingleton(() => StartExamUseCase(sl()));
  sl.registerLazySingleton(() => SubmitExamUseCase(sl()));
  sl.registerFactory(() => ExamsCubit(sl(), sl(), sl(), sl(), sl()));

  // Announcements
  sl.registerLazySingleton<AnnouncementsRemoteDataSource>(() => AnnouncementsRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<AnnouncementsRepository>(() => AnnouncementsRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton(() => GetAnnouncementsUseCase(sl()));
  sl.registerFactory(() => AnnouncementsCubit(sl()));

  // Notifications
  sl.registerLazySingleton<NotificationsRemoteDataSource>(() => NotificationsRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<NotificationsRepository>(() => NotificationsRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => MarkReadUseCase(sl()));
  sl.registerFactory(() => NotificationsCubit(sl(), sl()));

  // Profile (Student)
  sl.registerLazySingleton<ProfileRemoteDataSource>(() => ProfileRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerFactory(() => ProfileCubit(sl(), sl()));

  // Contract
  sl.registerLazySingleton<ContractRemoteDataSource>(() => ContractRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<ContractRepository>(() => ContractRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton(() => GetContractUseCase(sl()));
  sl.registerFactory(() => ContractCubit(sl()));

  // Educational Notes
  sl.registerLazySingleton<NotesRemoteDataSource>(() => NotesRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<NotesRepository>(() => NotesRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton(() => GetNotesUseCase(sl()));
  sl.registerFactory(() => NotesCubit(sl()));

  // Files
  sl.registerLazySingleton<FilesRemoteDataSource>(() => FilesRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<FilesRepository>(() => FilesRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton(() => GetFilesUseCase(sl()));
  sl.registerFactory(() => FilesCubit(sl()));

  // Teacher Home
  sl.registerLazySingleton<TeacherHomeRemoteDataSource>(() => TeacherHomeRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<TeacherHomeRepository>(() => TeacherHomeRepositoryImpl(sl(), sl(), sl()));
  sl.registerLazySingleton(() => GetTeacherHomeUseCase(sl()));
  sl.registerFactory(() => TeacherHomeCubit(sl()));

  // Classes
  sl.registerLazySingleton<ClassesRemoteDataSource>(() => ClassesRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<ClassesRepository>(() => ClassesRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton(() => GetClassesUseCase(sl()));
  sl.registerLazySingleton(() => GetClassStudentsUseCase(sl()));
  sl.registerFactory(() => ClassesCubit(sl(), sl()));

  // Teacher Attendance
  sl.registerLazySingleton<TeacherAttendanceRemoteDataSource>(() => TeacherAttendanceRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<TeacherAttendanceRepository>(() => TeacherAttendanceRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton(() => GetAttendanceClassesUseCase(sl()));
  sl.registerLazySingleton(() => SubmitAttendanceUseCase(sl()));
  sl.registerFactory(() => TeacherAttendanceCubit(sl(), sl(), sl()));

  // Teacher Grades
  sl.registerLazySingleton<TeacherGradesRemoteDataSource>(() => TeacherGradesRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<TeacherGradesRepository>(() => TeacherGradesRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton(() => GetTeacherGradesUseCase(sl()));
  sl.registerLazySingleton(() => SubmitGradesUseCase(sl()));
  sl.registerFactoryParam<TeacherGradesCubit, int, void>(
    (classId, _) => TeacherGradesCubit(
      classId: classId,
      getGrades: sl(),
      submitGrades: sl(),
      getClassStudents: sl(),
    ),
  );

  // Teacher Educational Notes
  sl.registerLazySingleton<TeacherNotesRemoteDataSource>(() => TeacherNotesRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<TeacherNotesRepository>(() => TeacherNotesRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton(() => GetClassNotesUseCase(sl()));
  sl.registerLazySingleton(() => CreateNoteUseCase(sl()));
  sl.registerLazySingleton(() => UpdateNoteUseCase(sl()));
  sl.registerLazySingleton(() => DeleteNoteUseCase(sl()));
  sl.registerFactoryParam<TeacherNotesCubit, int, void>(
    (classId, _) => TeacherNotesCubit(
      classId: classId,
      getClassNotes: sl(),
      createNote: sl(),
      updateNote: sl(),
      deleteNote: sl(),
    ),
  );

  // Teacher Profile
  sl.registerLazySingleton<TeacherProfileRemoteDataSource>(() => TeacherProfileRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<TeacherProfileRepository>(() => TeacherProfileRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton(() => GetTeacherProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTeacherProfileUseCase(sl()));
  sl.registerFactory(() => TeacherProfileCubit(sl(), sl()));

  // Teacher Common (class subjects lookup)
  sl.registerLazySingleton<TeacherCommonRemoteDataSource>(() => TeacherCommonRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<TeacherCommonRepository>(() => TeacherCommonRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton(() => GetClassSubjectsUseCase(sl()));

  // Teacher Files (question banks / previous-year exams / worksheets)
  sl.registerLazySingleton<TeacherFilesRemoteDataSource>(() => TeacherFilesRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<TeacherFilesRepository>(() => TeacherFilesRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton(() => GetTeacherFilesUseCase(sl()));
  sl.registerLazySingleton(() => CreateTeacherFileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTeacherFileUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTeacherFileUseCase(sl()));
  sl.registerFactoryParam<TeacherFilesCubit, TeacherFilesScope, void>(
    (scope, _) => TeacherFilesCubit(
      kind: scope.kind,
      classId: scope.classId,
      subjectId: scope.subjectId,
      getFiles: sl(),
      createFile: sl(),
      updateFile: sl(),
      deleteFile: sl(),
    ),
  );

  // Teacher Videos
  sl.registerLazySingleton<TeacherVideosRemoteDataSource>(() => TeacherVideosRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<TeacherVideosRepository>(() => TeacherVideosRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton(() => GetClassVideosUseCase(sl()));
  sl.registerLazySingleton(() => CreateVideoUseCase(sl()));
  sl.registerLazySingleton(() => DeleteVideoUseCase(sl()));
  sl.registerFactoryParam<TeacherVideosCubit, int, void>(
    (classId, _) => TeacherVideosCubit(
      classId: classId,
      getClassVideos: sl(),
      createVideo: sl(),
      deleteVideo: sl(),
    ),
  );

  // Teacher Exams
  sl.registerLazySingleton<TeacherExamsRemoteDataSource>(() => TeacherExamsRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<TeacherExamsRepository>(() => TeacherExamsRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton(() => GetTeacherExamsUseCase(sl()));
  sl.registerLazySingleton(() => GetTeacherExamDetailUseCase(sl()));
  sl.registerLazySingleton(() => CreateExamUseCase(sl()));
  sl.registerLazySingleton(() => UpdateExamUseCase(sl()));
  sl.registerLazySingleton(() => DeleteExamUseCase(sl()));
  sl.registerLazySingleton(() => CreateExamQuestionUseCase(sl()));
  sl.registerLazySingleton(() => UpdateExamQuestionUseCase(sl()));
  sl.registerLazySingleton(() => DeleteExamQuestionUseCase(sl()));
  sl.registerFactoryParam<TeacherExamsCubit, int, void>(
    (classId, _) => TeacherExamsCubit(
      classId: classId,
      getExams: sl(),
      createExam: sl(),
      deleteExam: sl(),
    ),
  );
  sl.registerFactoryParam<TeacherExamDetailCubit, int, void>(
    (examId, _) => TeacherExamDetailCubit(
      examId: examId,
      getExamDetail: sl(),
      updateExam: sl(),
      deleteExam: sl(),
      createQuestion: sl(),
      updateQuestion: sl(),
      deleteQuestion: sl(),
    ),
  );

  // Teacher Trips (bus live tracking — companion teacher)
  sl.registerLazySingleton<TripLocationService>(() => TripLocationService());
  sl.registerLazySingleton<TeacherTripsRemoteDataSource>(() => TeacherTripsRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<TeacherTripsRepository>(() => TeacherTripsRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton(() => GetMyTripsUseCase(sl()));
  sl.registerLazySingleton(() => StartTripUseCase(sl()));
  sl.registerLazySingleton(() => SendTripLocationUseCase(sl()));
  sl.registerLazySingleton(() => MarkTripStudentArrivedUseCase(sl()));
  sl.registerLazySingleton(() => CompleteTripUseCase(sl()));
  sl.registerFactory(() => TeacherTripsCubit(getMyTrips: sl(), startTrip: sl()));
  sl.registerFactoryParam<TripExecutionCubit, Trip, void>(
    (trip, _) => TripExecutionCubit(
      trip: trip,
      sendLocation: sl(),
      markArrived: sl(),
      completeTrip: sl(),
      locationService: sl(),
    ),
  );

  // Student Trip (bus live tracking — student view)
  sl.registerLazySingleton<StudentTripRemoteDataSource>(() => StudentTripRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<StudentTripRepository>(() => StudentTripRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton(() => GetMyTripUseCase(sl()));
  sl.registerFactory(() => StudentTripCubit(sl()));
}
