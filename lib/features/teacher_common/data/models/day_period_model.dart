import '../../domain/entities/day_period.dart';

class ClassDayPeriodModel extends ClassDayPeriod {
  const ClassDayPeriodModel({
    required super.periodNumber,
    required super.label,
    required super.startTime,
    required super.endTime,
    required super.subjectName,
    required super.teacherName,
  });

  factory ClassDayPeriodModel.fromJson(Map<String, dynamic> json) {
    final subject = json['subject'] as Map<String, dynamic>? ?? {};
    final teacher = json['teacher'] as Map<String, dynamic>? ?? {};
    return ClassDayPeriodModel(
      periodNumber: (json['period_number'] as num?)?.toInt() ?? 0,
      label: json['label'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      subjectName: subject['name'] as String? ?? '',
      teacherName: teacher['name'] as String? ?? '',
    );
  }
}
