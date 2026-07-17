import '../../domain/entities/teacher_home_data.dart';

class TeacherStatsModel extends TeacherStats {
  const TeacherStatsModel({
    required super.classesCount,
    required super.totalStudents,
    required super.todayPeriods,
    required super.pendingAttendance,
  });

  factory TeacherStatsModel.fromJson(Map<String, dynamic> json) {
    return TeacherStatsModel(
      classesCount: (json['classes_count'] as num?)?.toInt() ?? 0,
      totalStudents: (json['total_students'] as num?)?.toInt() ?? 0,
      todayPeriods: (json['today_periods'] as num?)?.toInt() ?? 0,
      pendingAttendance: (json['pending_attendance'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'classes_count': classesCount,
        'total_students': totalStudents,
        'today_periods': todayPeriods,
        'pending_attendance': pendingAttendance,
      };
}

class TodayPeriodModel extends TodayPeriod {
  const TodayPeriodModel({
    required super.periodNumber,
    required super.label,
    required super.startTime,
    required super.endTime,
    required super.className,
    required super.subjectName,
  });

  factory TodayPeriodModel.fromJson(Map<String, dynamic> json) {
    return TodayPeriodModel(
      periodNumber: (json['period_number'] as num?)?.toInt() ?? 0,
      label: json['label'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      className: (json['class'] as String?) ??
          (json['class_name'] as String?) ??
          '',
      subjectName: (json['subject'] as String?) ??
          (json['subject_name'] as String?) ??
          '',
    );
  }

  Map<String, dynamic> toJson() => {
        'period_number': periodNumber,
        'label': label,
        'start_time': startTime,
        'end_time': endTime,
        'class': className,
        'subject': subjectName,
      };
}

class TeacherHomeDataModel extends TeacherHomeData {
  const TeacherHomeDataModel({
    required super.teacherId,
    required super.teacherName,
    super.teacherAvatar,
    required TeacherStatsModel stats,
    required List<TodayPeriodModel> todaySchedule,
  }) : super(stats: stats, todaySchedule: todaySchedule);

  factory TeacherHomeDataModel.fromJson(Map<String, dynamic> json) {
    final teacherMap = json['teacher'] as Map<String, dynamic>? ?? {};
    final statsMap = json['stats'] as Map<String, dynamic>? ?? {};
    final scheduleList = json['today_schedule'] as List<dynamic>? ?? [];

    return TeacherHomeDataModel(
      teacherId: (teacherMap['id'] as num?)?.toInt() ?? 0,
      teacherName: teacherMap['name'] as String? ?? '',
      teacherAvatar: teacherMap['avatar'] as String?,
      stats: TeacherStatsModel.fromJson(statsMap),
      todaySchedule: scheduleList
          .map((e) => TodayPeriodModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  factory TeacherHomeDataModel.fromCacheJson(Map<String, dynamic> json) =>
      TeacherHomeDataModel.fromJson(json);

  Map<String, dynamic> toJson() => {
        'teacher': {
          'id': teacherId,
          'name': teacherName,
          'avatar': teacherAvatar,
        },
        'stats': (stats as TeacherStatsModel).toJson(),
        'today_schedule': (todaySchedule as List<TodayPeriodModel>)
            .map((p) => p.toJson())
            .toList(),
      };
}
