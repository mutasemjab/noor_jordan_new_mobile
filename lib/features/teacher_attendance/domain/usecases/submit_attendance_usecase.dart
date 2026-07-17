import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/teacher_attendance_repository.dart';

class SubmitAttendanceUseCase {
  final TeacherAttendanceRepository _repository;
  SubmitAttendanceUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required int classId,
    required String date,
    required List<Map<String, dynamic>> entries,
  }) =>
      _repository.submitAttendance(classId: classId, date: date, entries: entries);
}
