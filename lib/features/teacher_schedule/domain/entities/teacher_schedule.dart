import 'package:equatable/equatable.dart';

class TeacherPeriod extends Equatable {
  final int periodNumber;
  final String label;
  final String startTime;
  final String endTime;
  final String className;
  final String subjectName;

  const TeacherPeriod({
    required this.periodNumber,
    required this.label,
    required this.startTime,
    required this.endTime,
    required this.className,
    required this.subjectName,
  });

  @override
  List<Object?> get props => [periodNumber, label, startTime, endTime, className, subjectName];
}

class TeacherDaySchedule extends Equatable {
  final String day;
  final String dayName;
  final List<TeacherPeriod> periods;

  const TeacherDaySchedule({required this.day, required this.dayName, required this.periods});

  @override
  List<Object?> get props => [day, dayName, periods];
}
