import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_notes_usecase.dart';
import 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  final GetNotesUseCase _useCase;
  NotesCubit(this._useCase) : super(NotesInitial());

  Future<void> load() async {
    emit(NotesLoading());
    final result = await _useCase();
    result.fold(
      (f) => emit(NotesError(f.message)),
      (notes) => emit(NotesLoaded(notes)),
    );
  }
}
