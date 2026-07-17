import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_subjects_usecase.dart';
import '../../domain/usecases/get_subject_videos_usecase.dart';
import 'subjects_state.dart';

class SubjectsCubit extends Cubit<SubjectsState> {
  final GetSubjectsUseCase getSubjectsUseCase;
  final GetSubjectVideosUseCase getSubjectVideosUseCase;

  SubjectsCubit(this.getSubjectsUseCase, this.getSubjectVideosUseCase)
      : super(const SubjectsInitial());

  Future<void> loadSubjects() async {
    emit(const SubjectsLoading());
    final result = await getSubjectsUseCase();
    result.fold(
      (failure) => emit(SubjectsError(failure.message)),
      (subjects) => emit(SubjectsLoaded(subjects)),
    );
  }
}

class VideosCubit extends Cubit<VideosState> {
  final GetSubjectVideosUseCase getSubjectVideosUseCase;

  VideosCubit(this.getSubjectVideosUseCase) : super(const VideosInitial());

  Future<void> loadVideos(int subjectId) async {
    emit(const VideosLoading());
    final result = await getSubjectVideosUseCase(subjectId);
    result.fold(
      (failure) => emit(VideosError(failure.message)),
      (videos) => emit(VideosLoaded(videos)),
    );
  }
}
