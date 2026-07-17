import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/teacher_schedule.dart';
import '../repositories/teacher_schedule_repository.dart';

class GetTeacherScheduleUseCase {
  final TeacherScheduleRepository _repo;
  GetTeacherScheduleUseCase(this._repo);
  Future<Either<Failure, List<TeacherDaySchedule>>> call() => _repo.getSchedule();
}
