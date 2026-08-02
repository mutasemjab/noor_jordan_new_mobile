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

  final int classId;

  TeacherNotesCubit({
    required this.classId,
    required GetClassNotesUseCase getClassNotes,
    required CreateNoteUseCase createNote,
    required UpdateNoteUseCase updateNote,
    required DeleteNoteUseCase deleteNote,
  })  : _getClassNotes = getClassNotes,
        _createNote = createNote,
        _updateNote = updateNote,
        _deleteNote = deleteNote,
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
    required String title,
    required String description,
    required EducationalNoteType type,
    required DateTime date,
    File? attachment,
  }) async {
    final result = await _createNote(
      classId: classId,
      title: title,
      description: description,
      type: type,
      date: date,
      attachment: attachment,
    );
    return result.fold((f) => f.message, (_) {
      load();
      return null;
    });
  }

  Future<String?> update({
    required int noteId,
    required String title,
    required String description,
    required EducationalNoteType type,
    required DateTime date,
    File? attachment,
  }) async {
    final result = await _updateNote(
      noteId: noteId,
      title: title,
      description: description,
      type: type,
      date: date,
      attachment: attachment,
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
}
