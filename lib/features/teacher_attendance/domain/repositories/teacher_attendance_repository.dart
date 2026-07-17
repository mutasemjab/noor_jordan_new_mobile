import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/teacher_attendance.dart';

abstract class TeacherAttendanceRepository {
  Future<Either<Failure, List<TeacherAttendanceClass>>> getClasses();
  Future<Either<Failure, List<AttendanceEntry>>> getStudents(int classId);
  Future<Either<Failure, void>> submitAttendance({
    required int classId,
    required String date,
    required List<Map<String, dynamic>> entries,
  });
}
