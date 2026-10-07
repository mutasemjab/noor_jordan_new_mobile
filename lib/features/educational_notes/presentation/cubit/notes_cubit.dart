import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/note_browse_usecases.dart';
import 'notes_state.dart';

class NoteDatesCubit extends Cubit<NoteDatesState> {
  final GetNoteDatesUseCase _useCase;
  NoteDatesCubit(this._useCase) : super(NoteDatesInitial());

  Future<void> load() async {
    emit(NoteDatesLoading());
    final result = await _useCase();
    result.fold(
      (f) => emit(NoteDatesError(f.message)),
      (dates) => emit(NoteDatesLoaded(dates)),
    );
  }
}
