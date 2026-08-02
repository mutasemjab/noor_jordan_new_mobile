import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/exam_schedule.dart';
import '../repositories/exam_schedules_repository.dart';

class GetExamSchedulesUseCase {
  final ExamSchedulesRepository _repository;

  GetExamSchedulesUseCase(this._repository);

  Future<Either<Failure, List<ExamSchedule>>> call() {
    return _repository.getExamSchedules();
  }
}
