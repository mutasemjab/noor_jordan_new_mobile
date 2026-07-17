import '../../domain/entities/attendance.dart';

class AttendanceRecordModel extends AttendanceRecord {
  const AttendanceRecordModel({
    required super.date,
    super.period,
    required super.status,
    super.notes,
  });

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordModel(
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      period: json['period'] as int?,
      status: _parseStatus(json['status'] as String? ?? ''),
      notes: json['notes'] as String?,
    );
  }

  static AttendanceStatus _parseStatus(String raw) {
    switch (raw.toLowerCase().trim()) {
      case 'present':
        return AttendanceStatus.present;
      case 'absent':
        return AttendanceStatus.absent;
      case 'late':
        return AttendanceStatus.late;
      case 'excused':
        return AttendanceStatus.excused;
      default:
        return AttendanceStatus.absent;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'period': period,
      'status': _statusToString(status),
      'notes': notes,
    };
  }

  static String _statusToString(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'present';
      case AttendanceStatus.absent:
        return 'absent';
      case AttendanceStatus.late:
        return 'late';
      case AttendanceStatus.excused:
        return 'excused';
    }
  }
}

class AttendanceSummaryModel extends AttendanceSummary {
  const AttendanceSummaryModel({
    required super.present,
    required super.absent,
    required super.late,
    required super.excused,
    required super.percentage,
  });

  factory AttendanceSummaryModel.fromJson(Map<String, dynamic> json) {
    return AttendanceSummaryModel(
      present: json['present'] as int? ?? 0,
      absent: json['absent'] as int? ?? 0,
      late: json['late'] as int? ?? 0,
      excused: json['excused'] as int? ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'present': present,
      'absent': absent,
      'late': late,
      'excused': excused,
      'percentage': percentage,
    };
  }
}

class AttendanceDataModel extends AttendanceData {
  const AttendanceDataModel({
    required super.records,
    required super.summary,
  });

  factory AttendanceDataModel.fromJson(Map<String, dynamic> json) {
    final recordsJson = json['records'] as List<dynamic>? ?? [];
    final summaryJson =
        json['summary'] as Map<String, dynamic>? ?? {};

    return AttendanceDataModel(
      records: recordsJson
          .map((r) =>
              AttendanceRecordModel.fromJson(r as Map<String, dynamic>))
          .toList(),
      summary: AttendanceSummaryModel.fromJson(summaryJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'records': (records as List<AttendanceRecordModel>)
          .map((r) => (r as AttendanceRecordModel).toJson())
          .toList(),
      'summary': (summary as AttendanceSummaryModel).toJson(),
    };
  }
}
