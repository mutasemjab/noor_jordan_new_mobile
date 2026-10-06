import 'package:equatable/equatable.dart';

/// One period in a class's schedule for a specific day — used as a
/// read-only info banner (e.g. on the "مفكرتي" note form) to remind the
/// teacher what's taught in that class/day before they log a note.
class ClassDayPeriod extends Equatable {
  final int periodNumber;
  final String label;
  final String startTime;
  final String endTime;
  final String subjectName;
  final String teacherName;

  const ClassDayPeriod({
    required this.periodNumber,
    required this.label,
    required this.startTime,
    required this.endTime,
    required this.subjectName,
    required this.teacherName,
  });

  @override
  List<Object?> get props => [periodNumber, label, startTime, endTime, subjectName, teacherName];
}
