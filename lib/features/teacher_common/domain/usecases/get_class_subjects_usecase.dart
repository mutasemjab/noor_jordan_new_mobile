import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/teacher_subject.dart';
import '../repositories/teacher_common_repository.dart';

class GetClassSubjectsUseCase {
  final TeacherCommonRepository _repository;
  GetClassSubjectsUseCase(this._repository);
  Future<Either<Failure, List<TeacherSubject>>> call(int classId) => _repository.getClassSubjects(classId);
}
