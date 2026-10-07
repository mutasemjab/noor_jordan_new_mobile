import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/educational_note.dart';

abstract class NotesRepository {
  Future<Either<Failure, List<NoteDateSummary>>> getDates();

  Future<Either<Failure, List<NoteSubject>>> getSubjects(String date);

  Future<Either<Failure, List<NoteContentItem>>> getContent({
    required String date,
    required int subjectId,
  });
}
