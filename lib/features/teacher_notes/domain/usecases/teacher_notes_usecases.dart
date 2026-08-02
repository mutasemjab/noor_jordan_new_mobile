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
    required String title,
    required String description,
    required EducationalNoteType type,
    required DateTime date,
    File? attachment,
  }) =>
      _repository.createNote(
        classId: classId,
        title: title,
        description: description,
        type: type,
        date: date,
        attachment: attachment,
      );
}

class UpdateNoteUseCase {
  final TeacherNotesRepository _repository;
  UpdateNoteUseCase(this._repository);
  Future<Either<Failure, void>> call({
    required int noteId,
    required String title,
    required String description,
    required EducationalNoteType type,
    required DateTime date,
    File? attachment,
  }) =>
      _repository.updateNote(
        noteId: noteId,
        title: title,
        description: description,
        type: type,
        date: date,
        attachment: attachment,
      );
}

class DeleteNoteUseCase {
  final TeacherNotesRepository _repository;
  DeleteNoteUseCase(this._repository);
  Future<Either<Failure, void>> call(int noteId) => _repository.deleteNote(noteId);
}
