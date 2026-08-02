import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/teacher_video.dart';
import '../repositories/teacher_videos_repository.dart';

class GetClassVideosUseCase {
  final TeacherVideosRepository _repository;
  GetClassVideosUseCase(this._repository);
  Future<Either<Failure, List<TeacherVideo>>> call(int classId) => _repository.getClassVideos(classId);
}

class CreateVideoUseCase {
  final TeacherVideosRepository _repository;
  CreateVideoUseCase(this._repository);
  Future<Either<Failure, void>> call({
    required int classId,
    required int subjectId,
    required String title,
    required String youtubeUrl,
  }) =>
      _repository.createVideo(classId: classId, subjectId: subjectId, title: title, youtubeUrl: youtubeUrl);
}

class DeleteVideoUseCase {
  final TeacherVideosRepository _repository;
  DeleteVideoUseCase(this._repository);
  Future<Either<Failure, void>> call({required int classId, required int videoId}) =>
      _repository.deleteVideo(classId: classId, videoId: videoId);
}
