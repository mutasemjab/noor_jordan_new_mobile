import '../../domain/entities/schedule.dart';

class PeriodModel extends Period {
  const PeriodModel({
    required super.periodNumber,
    required super.label,
    required super.startTime,
    required super.endTime,
    required super.subjectName,
    super.subjectColor,
    required super.teacherName,
    super.teacherAvatar,
  });

  factory PeriodModel.fromJson(Map<String, dynamic> json) {
    final subject = json['subject'] as Map<String, dynamic>? ?? {};
    final teacher = json['teacher'] as Map<String, dynamic>? ?? {};

    return PeriodModel(
      periodNumber: (json['period_number'] as num?)?.toInt() ?? 0,
      label: json['label'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      subjectName: subject['name_ar'] as String? ??
          subject['name'] as String? ??
          json['subject_name'] as String? ??
          '',
      subjectColor: subject['color_class'] as String? ??
          json['subject_color'] as String?,
      teacherName: teacher['name'] as String? ?? json['teacher_name'] as String? ?? '',
      teacherAvatar: teacher['avatar'] as String? ?? json['teacher_avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period_number': periodNumber,
      'label': label,
      'start_time': startTime,
      'end_time': endTime,
      'subject': {
        'name_ar': subjectName,
        'color_class': subjectColor,
      },
      'teacher': {
        'name': teacherName,
        'avatar': teacherAvatar,
      },
    };
  }
}

class DayScheduleModel extends DaySchedule {
  const DayScheduleModel({
    required super.day,
    required super.dayName,
    required List<PeriodModel> periods,
  }) : super(periods: periods);

  factory DayScheduleModel.fromJson(Map<String, dynamic> json) {
    final periodsRaw = json['periods'] as List<dynamic>? ?? [];
    return DayScheduleModel(
      day: json['day'] as String? ?? '',
      dayName: json['name'] as String? ??
          json['day_name'] as String? ??
          _dayToArabic(json['day'] as String? ?? ''),
      periods: periodsRaw
          .map((e) => PeriodModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'name': dayName,
      'periods': (periods as List<PeriodModel>)
          .map((p) => (p as PeriodModel).toJson())
          .toList(),
    };
  }

  static String _dayToArabic(String day) {
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
}
