import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/teacher_subject.dart';

abstract class TeacherCommonRepository {
  Future<Either<Failure, List<TeacherSubject>>> getClassSubjects(int classId);
}
