import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../educational_notes/domain/entities/educational_note.dart';
import '../../domain/usecases/teacher_notes_usecases.dart';
import 'teacher_notes_state.dart';

class TeacherNotesCubit extends Cubit<TeacherNotesState> {
  final GetClassNotesUseCase _getClassNotes;
  final CreateNoteUseCase _createNote;
  final UpdateNoteUseCase _updateNote;
  final DeleteNoteUseCase _deleteNote;
  final DeleteNoteImageUseCase _deleteNoteImage;

  final int classId;

  TeacherNotesCubit({
    required this.classId,
    required GetClassNotesUseCase getClassNotes,
    required CreateNoteUseCase createNote,
    required UpdateNoteUseCase updateNote,
    required DeleteNoteUseCase deleteNote,
    required DeleteNoteImageUseCase deleteNoteImage,
  })  : _getClassNotes = getClassNotes,
        _createNote = createNote,
        _updateNote = updateNote,
        _deleteNote = deleteNote,
        _deleteNoteImage = deleteNoteImage,
        super(const TeacherNotesLoading());

  Future<void> load() async {
    emit(const TeacherNotesLoading());
    final result = await _getClassNotes(classId);
    result.fold(
      (f) => emit(TeacherNotesError(f.message)),
      (notes) => emit(TeacherNotesLoaded(notes)),
    );
  }

  /// Returns an error message on failure, or null on success.
  Future<String?> create({
    required int subjectId,
    required String title,
    required String description,
    required EducationalNoteType type,
    required DateTime date,
    File? attachment,
    List<File> images = const [],
  }) async {
    final result = await _createNote(
      classId: classId,
      subjectId: subjectId,
      title: title,
      description: description,
      type: type,
      date: date,
      attachment: attachment,
      images: images,
    );
    return result.fold((f) => f.message, (_) {
      load();
      return null;
    });
  }

  Future<String?> update({
    required int noteId,
    required int subjectId,
    required String title,
    required String description,
    required EducationalNoteType type,
    required DateTime date,
    File? attachment,
    List<File> images = const [],
  }) async {
    final result = await _updateNote(
      noteId: noteId,
      subjectId: subjectId,
      title: title,
      description: description,
      type: type,
      date: date,
      attachment: attachment,
      images: images,
    );
    return result.fold((f) => f.message, (_) {
      load();
      return null;
    });
  }

  Future<String?> delete(int noteId) async {
    final result = await _deleteNote(noteId);
    return result.fold((f) => f.message, (_) {
      load();
      return null;
    });
  }

  /// Deletes one existing image from a note. Unlike create/update, this does
  /// NOT reload the whole list — the form page removes it from local state
  /// itself so the rest of the in-progress edit isn't disturbed.
  Future<String?> deleteImage({required int noteId, required int imageId}) async {
    final result = await _deleteNoteImage(noteId: noteId, imageId: imageId);
    return result.fold((f) => f.message, (_) => null);
  }
}
