import 'package:equatable/equatable.dart';
import '../../domain/entities/teacher_video.dart';

abstract class TeacherVideosState extends Equatable {
  const TeacherVideosState();
  @override
  List<Object?> get props => [];
}

class TeacherVideosLoading extends TeacherVideosState {
  const TeacherVideosLoading();
}

class TeacherVideosLoaded extends TeacherVideosState {
  final List<TeacherVideo> videos;
  const TeacherVideosLoaded(this.videos);
  @override
  List<Object?> get props => [videos];
}

class TeacherVideosError extends TeacherVideosState {
  final String message;
  const TeacherVideosError(this.message);
  @override
  List<Object?> get props => [message];
}
