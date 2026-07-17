import 'package:equatable/equatable.dart';

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

class TodayPeriod extends Equatable {
  final int periodNumber;
  final String label;
  final String startTime;
  final String endTime;
  final String className;
  final String subjectName;

  const TodayPeriod({
    required this.periodNumber,
    required this.label,
    required this.startTime,
    required this.endTime,
    required this.className,
    required this.subjectName,
  });

  @override
  List<Object?> get props =>
      [periodNumber, label, startTime, endTime, className, subjectName];
}

class TeacherHomeData extends Equatable {
  final int teacherId;
  final String teacherName;
  final String? teacherAvatar;
  final TeacherStats stats;
  final List<TodayPeriod> todaySchedule;

  const TeacherHomeData({
    required this.teacherId,
    required this.teacherName,
    this.teacherAvatar,
    required this.stats,
    required this.todaySchedule,
  });

  @override
  List<Object?> get props =>
      [teacherId, teacherName, teacherAvatar, stats, todaySchedule];
}
