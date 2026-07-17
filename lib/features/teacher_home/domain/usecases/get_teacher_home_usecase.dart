import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/teacher_home_data.dart';
import '../repositories/teacher_home_repository.dart';

class GetTeacherHomeUseCase {
  final TeacherHomeRepository _repository;

  GetTeacherHomeUseCase(this._repository);

  Future<Either<Failure, TeacherHomeData>> call() {
    return _repository.getHome();
  }
}
