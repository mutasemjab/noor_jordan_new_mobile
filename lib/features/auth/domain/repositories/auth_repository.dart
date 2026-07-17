import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/student.dart';
import '../entities/teacher.dart';

abstract class AuthRepository {
  Future<Either<Failure, ({String token, Student student})>> loginStudent({
    required String phone,
    required String password,
  });

  Future<Either<Failure, ({String token, Teacher teacher})>> loginTeacher({
    required String email,
    required String password,
  });

  Future<Either<Failure, ({String token, Student student})>> switchSibling(
      int siblingId);

  Future<Either<Failure, void>> logout();
}
