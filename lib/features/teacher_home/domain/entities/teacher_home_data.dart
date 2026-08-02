import 'package:equatable/equatable.dart';
import '../../../classes/domain/entities/school_class.dart';
import '../../../home/domain/entities/home_data.dart' show Banner;

class TeacherStats extends Equatable {
  final int classesCount;
  final int totalStudents;
  final int todayPeriods;
  final int pendingAttendance;

  const TeacherStats({
    required this.classesCount,
    required this.totalStudents,
    required this.todayPeriods,
    required this.pendingAttendance,
  });

  @override
  List<Object?> get props =>
      [classesCount, totalStudents, todayPeriods, pendingAttendance];
}

class TeacherHomeData extends Equatable {
  final int teacherId;
  final String teacherName;
  final String? teacherAvatar;
  final TeacherStats stats;
  final List<Banner> banners;
  final List<SchoolClass> classes;

  const TeacherHomeData({
    required this.teacherId,
    required this.teacherName,
    this.teacherAvatar,
    required this.stats,
    required this.banners,
    required this.classes,
  });

  @override
  List<Object?> get props =>
      [teacherId, teacherName, teacherAvatar, stats, banners, classes];
}
