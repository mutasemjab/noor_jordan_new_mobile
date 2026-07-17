import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/student.dart';
import '../repositories/auth_repository.dart';

class LoginStudentUseCase {
  final AuthRepository _repo;
  LoginStudentUseCase(this._repo);

  Future<Either<Failure, ({String token, Student student})>> call({
    required String phone,
    required String password,
  }) {
    return _repo.loginStudent(phone: phone, password: password);
  }
}
