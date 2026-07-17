import '../../domain/entities/teacher_attendance.dart';

class TeacherAttendanceClassModel extends TeacherAttendanceClass {
  const TeacherAttendanceClassModel({
    required super.classId,
    required super.className,
    required super.subject,
    required super.periodNumber,
  });

  factory TeacherAttendanceClassModel.fromJson(Map<String, dynamic> json) {
    return TeacherAttendanceClassModel(
      classId: json['id'] as int,
      className: json['name'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      periodNumber: (json['period_number'] ?? json['periodNumber'] ?? 1) as int,
    );
  }
}

AttendanceStatus _parseStatus(String? s) {
  switch (s) {
    case 'absent': return AttendanceStatus.absent;
    case 'late': return AttendanceStatus.late;
    case 'excused': return AttendanceStatus.excused;
    default: return AttendanceStatus.present;
  }
}

class AttendanceEntryModel extends AttendanceEntry {
  const AttendanceEntryModel({
    required super.studentId,
    required super.studentName,
    super.avatarUrl,
    required super.status,
  });

  factory AttendanceEntryModel.fromJson(Map<String, dynamic> json) {
    return AttendanceEntryModel(
      studentId: json['id'] as int,
      studentName: json['name'] as String? ?? '',
      avatarUrl: json['avatar'] as String?,
      status: _parseStatus(json['status'] as String?),
    );
  }
}
