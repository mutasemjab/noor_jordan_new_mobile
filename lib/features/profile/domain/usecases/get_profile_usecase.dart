import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/student_profile.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository _repo;
  GetProfileUseCase(this._repo);
  Future<Either<Failure, StudentProfile>> call() => _repo.getProfile();
}
