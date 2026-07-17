import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/schedule.dart';
import '../repositories/schedule_repository.dart';

class GetScheduleUseCase {
  final ScheduleRepository _repository;

  GetScheduleUseCase(this._repository);

  Future<Either<Failure, List<DaySchedule>>> call() {
    return _repository.getSchedule();
  }
}
