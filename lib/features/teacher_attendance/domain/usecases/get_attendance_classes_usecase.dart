import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/teacher_attendance.dart';
import '../repositories/teacher_attendance_repository.dart';

class GetAttendanceClassesUseCase {
  final TeacherAttendanceRepository _repository;
  GetAttendanceClassesUseCase(this._repository);

  Future<Either<Failure, List<TeacherAttendanceClass>>> call() => _repository.getClasses();
}
