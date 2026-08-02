import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/exam_schedule.dart';

abstract class ExamSchedulesRepository {
  Future<Either<Failure, List<ExamSchedule>>> getExamSchedules();
}
