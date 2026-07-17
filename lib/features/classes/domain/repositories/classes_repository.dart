import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/school_class.dart';

abstract class ClassesRepository {
  Future<Either<Failure, List<SchoolClass>>> getClasses();
  Future<Either<Failure, List<ClassStudent>>> getClassStudents(int classId);
}
