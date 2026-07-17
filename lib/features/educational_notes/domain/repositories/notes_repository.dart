import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/educational_note.dart';

abstract class NotesRepository {
  Future<Either<Failure, List<EducationalNote>>> getNotes();
}
