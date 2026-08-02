import 'package:equatable/equatable.dart';
import '../../../educational_notes/domain/entities/educational_note.dart';

abstract class TeacherNotesState extends Equatable {
  const TeacherNotesState();
  @override
  List<Object?> get props => [];
}

class TeacherNotesLoading extends TeacherNotesState {
  const TeacherNotesLoading();
}

class TeacherNotesLoaded extends TeacherNotesState {
  final List<EducationalNote> notes;
  const TeacherNotesLoaded(this.notes);
  @override
  List<Object?> get props => [notes];
}

class TeacherNotesError extends TeacherNotesState {
  final String message;
  const TeacherNotesError(this.message);
  @override
  List<Object?> get props => [message];
}
