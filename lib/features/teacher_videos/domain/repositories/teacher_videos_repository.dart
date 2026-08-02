import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/teacher_video.dart';

abstract class TeacherVideosRepository {
  Future<Either<Failure, List<TeacherVideo>>> getClassVideos(int classId);

  Future<Either<Failure, void>> createVideo({
    required int classId,
    required int subjectId,
    required String title,
    required String youtubeUrl,
  });

  Future<Either<Failure, void>> deleteVideo({required int classId, required int videoId});
}
