import 'package:equatable/equatable.dart';

enum AttendanceStatus { present, absent, late, excused }

class AttendanceRecord extends Equatable {
  final DateTime date;
  final int? period;
  final AttendanceStatus status;
  final String? notes;

  const AttendanceRecord({
    required this.date,
    this.period,
    required this.status,
    this.notes,
  });

  @override
  List<Object?> get props => [date, period, status, notes];
}

class AttendanceSummary extends Equatable {
  final int present;
  final int absent;
  final int late;
  final int excused;
  final double percentage;

  const AttendanceSummary({
    required this.present,
    required this.absent,
    required this.late,
    required this.excused,
    required this.percentage,
  });

  @override
  List<Object?> get props => [present, absent, late, excused, percentage];
}

class AttendanceData extends Equatable {
  final List<AttendanceRecord> records;
  final AttendanceSummary summary;

  const AttendanceData({
    required this.records,
    required this.summary,
  });

  @override
  List<Object?> get props => [records, summary];
}
