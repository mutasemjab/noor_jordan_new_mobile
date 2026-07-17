import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/student_profile.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository _repo;
  UpdateProfileUseCase(this._repo);

  Future<Either<Failure, StudentProfile>> call({
    required String name,
    required String phone,
    String? avatarPath,
  }) =>
      _repo.updateProfile(name: name, phone: phone, avatarPath: avatarPath);
}
