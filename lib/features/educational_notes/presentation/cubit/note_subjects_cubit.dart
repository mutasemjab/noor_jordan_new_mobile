import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/note_browse_usecases.dart';
import 'note_subjects_state.dart';

class NoteSubjectsCubit extends Cubit<NoteSubjectsState> {
  final GetNoteSubjectsUseCase _useCase;
  final String date;

  NoteSubjectsCubit({required this.date, required GetNoteSubjectsUseCase useCase})
      : _useCase = useCase,
        super(const NoteSubjectsLoading());

  Future<void> load() async {
    emit(const NoteSubjectsLoading());
    final result = await _useCase(date);
    result.fold(
      (f) => emit(NoteSubjectsError(f.message)),
      (subjects) => emit(NoteSubjectsLoaded(subjects)),
    );
  }
}
