import 'dart:io';

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../educational_notes/domain/entities/educational_note.dart';
import '../repositories/teacher_notes_repository.dart';

class GetClassNotesUseCase {
  final TeacherNotesRepository _repository;
  GetClassNotesUseCase(this._repository);
  Future<Either<Failure, List<EducationalNote>>> call(int classId) => _repository.getClassNotes(classId);
}

class CreateNoteUseCase {
  final TeacherNotesRepository _repository;
  CreateNoteUseCase(this._repository);
  Future<Either<Failure, void>> call({
    required int classId,
    required int subjectId,
    required String title,
    required String description,
    required EducationalNoteType type,
    required DateTime date,
    File? attachment,
    List<File> images = const [],
  }) =>
      _repository.createNote(
        classId: classId,
        subjectId: subjectId,
        title: title,
        description: description,
        type: type,
        date: date,
        attachment: attachment,
        images: images,
      );
}

class UpdateNoteUseCase {
  final TeacherNotesRepository _repository;
  UpdateNoteUseCase(this._repository);
  Future<Either<Failure, void>> call({
    required int noteId,
    required int subjectId,
    required String title,
    required String description,
    required EducationalNoteType type,
    required DateTime date,
    File? attachment,
    List<File> images = const [],
  }) =>
      _repository.updateNote(
        noteId: noteId,
        subjectId: subjectId,
        title: title,
        description: description,
        type: type,
        date: date,
        attachment: attachment,
        images: images,
      );
}

class DeleteNoteUseCase {
  final TeacherNotesRepository _repository;
  DeleteNoteUseCase(this._repository);
  Future<Either<Failure, void>> call(int noteId) => _repository.deleteNote(noteId);
}

class DeleteNoteImageUseCase {
  final TeacherNotesRepository _repository;
  DeleteNoteImageUseCase(this._repository);
  Future<Either<Failure, void>> call({required int noteId, required int imageId}) =>
      _repository.deleteNoteImage(noteId: noteId, imageId: imageId);
}
