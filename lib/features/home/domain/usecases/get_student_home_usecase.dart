import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/home_data.dart';
import '../repositories/home_repository.dart';

class GetStudentHomeUseCase {
  final HomeRepository _repository;

  GetStudentHomeUseCase(this._repository);

  Future<Either<Failure, StudentHomeData>> call() {
    return _repository.getStudentHome();
  }
}
