import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/teacher_external_link.dart';

abstract class TeacherExternalLinksRepository {
  Future<Either<Failure, List<TeacherExternalLink>>> getLinks({int? classId, int? subjectId});

  Future<Either<Failure, void>> createLink({
    required int classId,
    required int subjectId,
    required String url,
  });

  Future<Either<Failure, void>> updateLink({required int id, required String url});

  Future<Either<Failure, void>> deleteLink(int id);
}
