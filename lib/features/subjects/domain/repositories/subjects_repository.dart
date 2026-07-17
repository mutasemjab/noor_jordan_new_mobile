import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/subject.dart';
import '../entities/subject_video.dart';

abstract class SubjectsRepository {
  Future<Either<Failure, List<Subject>>> getSubjects();
  Future<Either<Failure, List<SubjectVideo>>> getSubjectVideos(int subjectId);
}
