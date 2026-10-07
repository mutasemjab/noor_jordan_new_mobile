import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/teacher_external_link.dart';
import '../repositories/teacher_external_links_repository.dart';

class GetTeacherExternalLinksUseCase {
  final TeacherExternalLinksRepository _repository;
  GetTeacherExternalLinksUseCase(this._repository);
  Future<Either<Failure, List<TeacherExternalLink>>> call({int? classId, int? subjectId}) =>
      _repository.getLinks(classId: classId, subjectId: subjectId);
}

class CreateExternalLinkUseCase {
  final TeacherExternalLinksRepository _repository;
  CreateExternalLinkUseCase(this._repository);
  Future<Either<Failure, void>> call({required int classId, required int subjectId, required String url}) =>
      _repository.createLink(classId: classId, subjectId: subjectId, url: url);
}

class UpdateExternalLinkUseCase {
  final TeacherExternalLinksRepository _repository;
  UpdateExternalLinkUseCase(this._repository);
  Future<Either<Failure, void>> call({required int id, required String url}) =>
      _repository.updateLink(id: id, url: url);
}

class DeleteExternalLinkUseCase {
  final TeacherExternalLinksRepository _repository;
  DeleteExternalLinkUseCase(this._repository);
  Future<Either<Failure, void>> call(int id) => _repository.deleteLink(id);
}
