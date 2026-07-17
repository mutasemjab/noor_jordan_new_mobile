import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/teacher_profile.dart';

abstract class TeacherProfileRepository {
  Future<Either<Failure, TeacherProfile>> getProfile();
  Future<Either<Failure, TeacherProfile>> updateProfile({
    required String name,
    required String phone,
    String? avatarPath,
  });
}
