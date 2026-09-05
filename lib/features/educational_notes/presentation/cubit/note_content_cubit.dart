import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/note_browse_usecases.dart';
import 'note_content_state.dart';

class NoteContentCubit extends Cubit<NoteContentState> {
  final GetNoteContentUseCase _useCase;
  final String date;
  final int subjectId;

  NoteContentCubit({
    required this.date,
    required this.subjectId,
    required GetNoteContentUseCase useCase,
  })  : _useCase = useCase,
        super(const NoteContentLoading());

  Future<void> load() async {
    emit(const NoteContentLoading());
    final result = await _useCase(date: date, subjectId: subjectId);
    result.fold(
      (f) => emit(NoteContentError(f.message)),
      (items) => emit(NoteContentLoaded(items)),
    );
  }
}
