import 'package:equatable/equatable.dart';
import '../../domain/entities/file_item.dart';

abstract class FilesState extends Equatable {
  const FilesState();
  @override
  List<Object?> get props => [];
}

class FilesInitial extends FilesState {}
class FilesLoading extends FilesState {}

class FilesLoaded extends FilesState {
  final List<FileItem> previousExams;
  final List<FileItem> questionBanks;
  final List<FileItem> worksheets;
  const FilesLoaded(this.previousExams, this.questionBanks, this.worksheets);
  @override
  List<Object?> get props => [previousExams, questionBanks, worksheets];
}

class FilesError extends FilesState {
  final String message;
  const FilesError(this.message);
  @override
  List<Object?> get props => [message];
}
