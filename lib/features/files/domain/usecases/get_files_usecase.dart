import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/file_item.dart';
import '../repositories/files_repository.dart';

class GetFilesUseCase {
  final FilesRepository _repository;

  GetFilesUseCase(this._repository);

  Future<Either<Failure, List<FileItem>>> getPreviousExams() {
    return _repository.getPreviousExams();
  }

  Future<Either<Failure, List<FileItem>>> getQuestionBanks() {
    return _repository.getQuestionBanks();
  }

  Future<Either<Failure, List<FileItem>>> getWorksheets() {
    return _repository.getWorksheets();
  }
}
