import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/file_item.dart';

abstract class FilesRepository {
  Future<Either<Failure, List<FileItem>>> getPreviousExams();
  Future<Either<Failure, List<FileItem>>> getQuestionBanks();
  Future<Either<Failure, List<FileItem>>> getWorksheets();
}
