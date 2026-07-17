import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/subject_video.dart';
import '../repositories/subjects_repository.dart';

class GetSubjectVideosUseCase {
  final SubjectsRepository repository;
  GetSubjectVideosUseCase(this.repository);

  Future<Either<Failure, List<SubjectVideo>>> call(int subjectId) {
    return repository.getSubjectVideos(subjectId);
  }
}
