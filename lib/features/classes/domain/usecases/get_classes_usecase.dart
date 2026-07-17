import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/school_class.dart';
import '../repositories/classes_repository.dart';

class GetClassesUseCase {
  final ClassesRepository _repository;
  GetClassesUseCase(this._repository);

  Future<Either<Failure, List<SchoolClass>>> call() => _repository.getClasses();
}
