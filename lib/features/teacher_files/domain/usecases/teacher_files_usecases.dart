import 'dart:io';

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/teacher_file_item.dart';
import '../repositories/teacher_files_repository.dart';

class GetTeacherFilesUseCase {
  final TeacherFilesRepository _repository;
  GetTeacherFilesUseCase(this._repository);
  Future<Either<Failure, List<TeacherFileItem>>> call({
    required TeacherFileKind kind,
    int? classId,
    int? subjectId,
  }) =>
      _repository.getFiles(kind: kind, classId: classId, subjectId: subjectId);
}

class CreateTeacherFileUseCase {
  final TeacherFilesRepository _repository;
  CreateTeacherFileUseCase(this._repository);
  Future<Either<Failure, void>> call({
    required TeacherFileKind kind,
    required int classId,
    required int subjectId,
    required String title,
    int? year,
    required File file,
  }) =>
      _repository.createFile(kind: kind, classId: classId, subjectId: subjectId, title: title, year: year, file: file);
}

class UpdateTeacherFileUseCase {
  final TeacherFilesRepository _repository;
  UpdateTeacherFileUseCase(this._repository);
  Future<Either<Failure, void>> call({
    required TeacherFileKind kind,
    required int id,
    required String title,
    int? year,
    File? file,
  }) =>
      _repository.updateFile(kind: kind, id: id, title: title, year: year, file: file);
}

class DeleteTeacherFileUseCase {
  final TeacherFilesRepository _repository;
  DeleteTeacherFileUseCase(this._repository);
  Future<Either<Failure, void>> call({required TeacherFileKind kind, required int id}) =>
      _repository.deleteFile(kind: kind, id: id);
}
