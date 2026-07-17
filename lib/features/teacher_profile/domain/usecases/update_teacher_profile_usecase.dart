import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/teacher_profile.dart';
import '../repositories/teacher_profile_repository.dart';

class UpdateTeacherProfileUseCase {
  final TeacherProfileRepository _repository;
  UpdateTeacherProfileUseCase(this._repository);

  Future<Either<Failure, TeacherProfile>> call({
    required String name,
    required String phone,
    String? avatarPath,
  }) =>
      _repository.updateProfile(name: name, phone: phone, avatarPath: avatarPath);
}
