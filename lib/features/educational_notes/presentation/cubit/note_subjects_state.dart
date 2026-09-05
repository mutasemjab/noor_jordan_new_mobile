import 'package:equatable/equatable.dart';
import '../../domain/entities/educational_note.dart';

abstract class NoteSubjectsState extends Equatable {
  const NoteSubjectsState();
  @override
  List<Object?> get props => [];
}

class NoteSubjectsLoading extends NoteSubjectsState {
  const NoteSubjectsLoading();
}

class NoteSubjectsLoaded extends NoteSubjectsState {
  final List<NoteSubject> subjects;
  const NoteSubjectsLoaded(this.subjects);
  @override
  List<Object?> get props => [subjects];
}

class NoteSubjectsError extends NoteSubjectsState {
  final String message;
  const NoteSubjectsError(this.message);
  @override
  List<Object?> get props => [message];
}
