import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/educational_note.dart';
import '../repositories/notes_repository.dart';

class GetNoteDatesUseCase {
  final NotesRepository _repo;
  GetNoteDatesUseCase(this._repo);
  Future<Either<Failure, List<NoteDateSummary>>> call() => _repo.getDates();
}

class GetNoteSubjectsUseCase {
  final NotesRepository _repo;
  GetNoteSubjectsUseCase(this._repo);
  Future<Either<Failure, List<NoteSubject>>> call(String date) => _repo.getSubjects(date);
}

class GetNoteContentUseCase {
  final NotesRepository _repo;
  GetNoteContentUseCase(this._repo);
  Future<Either<Failure, List<NoteContentItem>>> call({required String date, required int subjectId}) =>
      _repo.getContent(date: date, subjectId: subjectId);
}
