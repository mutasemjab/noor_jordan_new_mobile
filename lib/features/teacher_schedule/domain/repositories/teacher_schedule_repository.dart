import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/teacher_schedule.dart';

abstract class TeacherScheduleRepository {
  Future<Either<Failure, List<TeacherDaySchedule>>> getSchedule();
}
