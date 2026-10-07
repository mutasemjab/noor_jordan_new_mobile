import 'package:equatable/equatable.dart';
import '../../domain/entities/educational_note.dart';

abstract class NoteContentState extends Equatable {
  const NoteContentState();
  @override
  List<Object?> get props => [];
}

class NoteContentLoading extends NoteContentState {
  const NoteContentLoading();
}

class NoteContentLoaded extends NoteContentState {
  final List<NoteContentItem> items;
  const NoteContentLoaded(this.items);

  List<NoteContentItem> get lessons => items.where((n) => n.type == EducationalNoteType.lesson).toList();
  List<NoteContentItem> get homework => items.where((n) => n.type == EducationalNoteType.homework).toList();

  @override
  List<Object?> get props => [items];
}

class NoteContentError extends NoteContentState {
  final String message;
  const NoteContentError(this.message);
  @override
  List<Object?> get props => [message];
}
