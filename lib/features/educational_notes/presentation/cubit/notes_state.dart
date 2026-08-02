import 'package:equatable/equatable.dart';
import '../../domain/entities/educational_note.dart';

abstract class NotesState extends Equatable {
  const NotesState();
  @override
  List<Object?> get props => [];
}

class NotesInitial extends NotesState {}

class NotesLoading extends NotesState {}

class NotesLoaded extends NotesState {
  final List<EducationalNote> notes;
  const NotesLoaded(this.notes);

  /// Distinct days that have notes, newest first.
  List<DateTime> get days {
    final set = <DateTime>{};
    for (final n in notes) {
      set.add(DateTime(n.date.year, n.date.month, n.date.day));
    }
    final list = set.toList()..sort((a, b) => b.compareTo(a));
    return list;
  }

  List<EducationalNote> notesForDay(DateTime day) {
    return notes
        .where((n) => n.date.year == day.year && n.date.month == day.month && n.date.day == day.day)
        .toList();
  }

  @override
  List<Object?> get props => [notes];
}

class NotesError extends NotesState {
  final String message;
  const NotesError(this.message);
  @override
  List<Object?> get props => [message];
}
