import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/student_profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, StudentProfile>> getProfile();
  Future<Either<Failure, StudentProfile>> updateProfile({
    required String name,
    required String phone,
    String? avatarPath,
  });
}
