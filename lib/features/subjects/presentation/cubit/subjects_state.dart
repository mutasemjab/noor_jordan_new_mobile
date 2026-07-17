import 'package:equatable/equatable.dart';
import '../../domain/entities/subject.dart';
import '../../domain/entities/subject_video.dart';

abstract class SubjectsState extends Equatable {
  const SubjectsState();
  @override
  List<Object?> get props => [];
}

class SubjectsInitial extends SubjectsState {
  const SubjectsInitial();
}

class SubjectsLoading extends SubjectsState {
  const SubjectsLoading();
}

class SubjectsLoaded extends SubjectsState {
  final List<Subject> subjects;
  const SubjectsLoaded(this.subjects);
  @override
  List<Object?> get props => [subjects];
}

class SubjectsError extends SubjectsState {
  final String message;
  const SubjectsError(this.message);
  @override
  List<Object?> get props => [message];
}

// Videos states
abstract class VideosState extends Equatable {
  const VideosState();
  @override
  List<Object?> get props => [];
}

class VideosInitial extends VideosState {
  const VideosInitial();
}

class VideosLoading extends VideosState {
  const VideosLoading();
}

class VideosLoaded extends VideosState {
  final List<SubjectVideo> videos;
  const VideosLoaded(this.videos);
  @override
  List<Object?> get props => [videos];
}

class VideosError extends VideosState {
  final String message;
  const VideosError(this.message);
  @override
  List<Object?> get props => [message];
}
