import 'package:equatable/equatable.dart';

class Period extends Equatable {
  final int periodNumber;
  final String label;
  final String startTime;
  final String endTime;
  final String subjectName;
  final String? subjectColor;
  final String teacherName;
  final String? teacherAvatar;

  const Period({
    required this.periodNumber,
    required this.label,
    required this.startTime,
    required this.endTime,
    required this.subjectName,
    this.subjectColor,
    required this.teacherName,
    this.teacherAvatar,
  });

  @override
  List<Object?> get props => [
        periodNumber,
        label,
        startTime,
        endTime,
        subjectName,
        subjectColor,
        teacherName,
        teacherAvatar,
      ];
}

class DaySchedule extends Equatable {
  final String day;
  final String dayName;
  final List<Period> periods;

  const DaySchedule({
    required this.day,
    required this.dayName,
    required this.periods,
  });

  @override
  List<Object?> get props => [day, dayName, periods];
}
