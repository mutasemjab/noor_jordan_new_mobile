import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/day_period.dart';
import '../repositories/teacher_common_repository.dart';

class GetClassDayScheduleUseCase {
  final TeacherCommonRepository _repository;
  GetClassDayScheduleUseCase(this._repository);
  Future<Either<Failure, List<ClassDayPeriod>>> call({required int classId, required String date}) =>
      _repository.getClassDaySchedule(classId: classId, date: date);
}
