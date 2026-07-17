import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/school_class.dart';
import '../repositories/classes_repository.dart';

class GetClassStudentsUseCase {
  final ClassesRepository _repository;
  GetClassStudentsUseCase(this._repository);

  Future<Either<Failure, List<ClassStudent>>> call(int classId) =>
      _repository.getClassStudents(classId);
}
