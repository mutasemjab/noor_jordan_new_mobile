import 'dart:io';

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../educational_notes/domain/entities/educational_note.dart';

abstract class TeacherNotesRepository {
  Future<Either<Failure, List<EducationalNote>>> getClassNotes(int classId);

  Future<Either<Failure, void>> createNote({
    required int classId,
    required String title,
    required String description,
    required EducationalNoteType type,
    required DateTime date,
    File? attachment,
  });

  Future<Either<Failure, void>> updateNote({
    required int noteId,
    required String title,
    required String description,
    required EducationalNoteType type,
    required DateTime date,
    File? attachment,
  });

  Future<Either<Failure, void>> deleteNote(int noteId);
}
