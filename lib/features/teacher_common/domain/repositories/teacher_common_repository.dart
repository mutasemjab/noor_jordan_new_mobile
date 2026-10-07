import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/day_period.dart';
import '../entities/teacher_subject.dart';

abstract class TeacherCommonRepository {
  Future<Either<Failure, List<TeacherSubject>>> getClassSubjects(int classId);

  Future<Either<Failure, List<ClassDayPeriod>>> getClassDaySchedule({required int classId, required String date});
}
