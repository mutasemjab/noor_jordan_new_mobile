import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/student.dart';
import '../entities/teacher.dart';

abstract class AuthRepository {
  Future<Either<Failure, ({String token, Student student})>> loginStudent({
    required String nationalId,
    required String password,
    String? fcmToken,
  });

  Future<Either<Failure, ({String token, Teacher teacher})>> loginTeacher({
    required String nationalId,
    required String password,
    String? fcmToken,
  });

  Future<Either<Failure, ({String token, Student student})>> switchSibling(
      int siblingId);

  Future<Either<Failure, void>> logout();
}
