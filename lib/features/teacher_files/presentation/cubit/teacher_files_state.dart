import 'package:equatable/equatable.dart';
import '../../domain/entities/teacher_file_item.dart';

abstract class TeacherFilesState extends Equatable {
  const TeacherFilesState();
  @override
  List<Object?> get props => [];
}

class TeacherFilesLoading extends TeacherFilesState {
  const TeacherFilesLoading();
}

class TeacherFilesLoaded extends TeacherFilesState {
  final List<TeacherFileItem> files;
  const TeacherFilesLoaded(this.files);
  @override
  List<Object?> get props => [files];
}

class TeacherFilesError extends TeacherFilesState {
  final String message;
  const TeacherFilesError(this.message);
  @override
  List<Object?> get props => [message];
}
