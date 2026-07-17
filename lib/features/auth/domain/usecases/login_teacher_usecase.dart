import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/teacher.dart';
import '../repositories/auth_repository.dart';

class LoginTeacherUseCase {
  final AuthRepository _repo;
  LoginTeacherUseCase(this._repo);

  Future<Either<Failure, ({String token, Teacher teacher})>> call({
    required String email,
    required String password,
  }) {
    return _repo.loginTeacher(email: email, password: password);
  }
}
