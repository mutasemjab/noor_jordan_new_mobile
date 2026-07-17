import 'package:equatable/equatable.dart';

enum AttendanceStatus { present, absent, late, excused }

class AttendanceEntry extends Equatable {
  final int studentId;
  final String studentName;
  final String? avatarUrl;
  final AttendanceStatus status;

  const AttendanceEntry({
    required this.studentId,
    required this.studentName,
    this.avatarUrl,
    required this.status,
  });

  AttendanceEntry copyWith({AttendanceStatus? status}) {
    return AttendanceEntry(
      studentId: studentId,
      studentName: studentName,
      avatarUrl: avatarUrl,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [studentId, studentName, avatarUrl, status];
}

class TeacherAttendanceClass extends Equatable {
  final int classId;
  final String className;
  final String subject;
  final int periodNumber;

  const TeacherAttendanceClass({
    required this.classId,
    required this.className,
    required this.subject,
    required this.periodNumber,
  });

  @override
  List<Object?> get props => [classId, className, subject, periodNumber];
}
