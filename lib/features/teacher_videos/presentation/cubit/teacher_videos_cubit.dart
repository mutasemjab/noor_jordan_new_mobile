import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/teacher_videos_usecases.dart';
import 'teacher_videos_state.dart';

class TeacherVideosCubit extends Cubit<TeacherVideosState> {
  final GetClassVideosUseCase _getClassVideos;
  final CreateVideoUseCase _createVideo;
  final DeleteVideoUseCase _deleteVideo;
  final int classId;

  TeacherVideosCubit({
    required this.classId,
    required GetClassVideosUseCase getClassVideos,
    required CreateVideoUseCase createVideo,
    required DeleteVideoUseCase deleteVideo,
  })  : _getClassVideos = getClassVideos,
        _createVideo = createVideo,
        _deleteVideo = deleteVideo,
        super(const TeacherVideosLoading());

  Future<void> load() async {
    emit(const TeacherVideosLoading());
    final result = await _getClassVideos(classId);
    result.fold(
      (f) => emit(TeacherVideosError(f.message)),
      (videos) => emit(TeacherVideosLoaded(videos)),
    );
  }

  Future<String?> create({required int subjectId, required String title, required String youtubeUrl}) async {
    final result = await _createVideo(classId: classId, subjectId: subjectId, title: title, youtubeUrl: youtubeUrl);
    return result.fold((f) => f.message, (_) {
      load();
      return null;
    });
  }

  Future<String?> delete(int videoId) async {
    final result = await _deleteVideo(classId: classId, videoId: videoId);
    return result.fold((f) => f.message, (_) {
      load();
      return null;
    });
  }
}
