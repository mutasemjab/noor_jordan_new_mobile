import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/teacher_home_data.dart';

abstract class TeacherHomeRepository {
  Future<Either<Failure, TeacherHomeData>> getHome();
}
