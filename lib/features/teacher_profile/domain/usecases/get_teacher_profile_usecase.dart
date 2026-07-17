import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/teacher_profile.dart';
import '../repositories/teacher_profile_repository.dart';

class GetTeacherProfileUseCase {
  final TeacherProfileRepository _repository;
  GetTeacherProfileUseCase(this._repository);

  Future<Either<Failure, TeacherProfile>> call() => _repository.getProfile();
}
