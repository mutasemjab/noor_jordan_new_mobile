import '../../domain/entities/teacher_schedule.dart';

class TeacherPeriodModel extends TeacherPeriod {
  const TeacherPeriodModel({
    required super.periodNumber,
    required super.label,
    required super.startTime,
    required super.endTime,
    required super.className,
    required super.subjectName,
  });

  factory TeacherPeriodModel.fromJson(Map<String, dynamic> json) {
    final cls = json['class'];
    final sub = json['subject'];
    return TeacherPeriodModel(
      periodNumber: json['period_number'] as int? ?? 0,
      label: (json['label'] ?? 'الحصة') as String,
      startTime: (json['start_time'] ?? '') as String,
      endTime: (json['end_time'] ?? '') as String,
      className: cls is Map ? (cls['name'] ?? '') as String : (cls ?? '') as String,
      subjectName: sub is Map ? (sub['name_ar'] ?? sub['name'] ?? '') as String : (sub ?? '') as String,
    );
  }
}

class TeacherDayScheduleModel extends TeacherDaySchedule {
  const TeacherDayScheduleModel({required super.day, required super.dayName, required super.periods});

  factory TeacherDayScheduleModel.fromJson(Map<String, dynamic> json) {
    final periods = (json['periods'] as List<dynamic>?)
            ?.map((p) => TeacherPeriodModel.fromJson(p as Map<String, dynamic>))
            .toList() ??
        [];
    return TeacherDayScheduleModel(
      day: (json['day'] ?? '') as String,
      dayName: (json['name'] ?? json['day_name'] ?? '') as String,
      periods: periods,
    );
  }
}
