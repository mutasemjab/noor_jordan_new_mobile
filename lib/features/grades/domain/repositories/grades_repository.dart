import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/grade.dart';

abstract class GradesRepository {
  Future<Either<Failure, List<SubjectGrades>>> getGrades();
}
