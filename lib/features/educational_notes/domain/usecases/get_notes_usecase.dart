import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/educational_note.dart';
import '../repositories/notes_repository.dart';

class GetNotesUseCase {
  final NotesRepository _repo;
  GetNotesUseCase(this._repo);
  Future<Either<Failure, List<EducationalNote>>> call() => _repo.getNotes();
}
