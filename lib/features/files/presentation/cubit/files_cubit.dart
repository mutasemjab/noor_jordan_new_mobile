import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_files_usecase.dart';
import 'files_state.dart';

class FilesCubit extends Cubit<FilesState> {
  final GetFilesUseCase _useCase;
  FilesCubit(this._useCase) : super(FilesInitial());

  Future<void> loadAll() async {
    emit(FilesLoading());
    final results = await Future.wait([
      _useCase.getPreviousExams(),
      _useCase.getQuestionBanks(),
      _useCase.getWorksheets(),
    ]);
    final prev = results[0];
    final qb = results[1];
    final ws = results[2];
    // If any fails, show error for first failure
    String? errorMsg;
    for (final r in results) {
      r.fold((f) => errorMsg = f.message, (_) {});
      if (errorMsg != null) break;
    }
    if (errorMsg != null) {
      emit(FilesError(errorMsg!));
      return;
    }
    emit(FilesLoaded(
      prev.getOrElse(() => []),
      qb.getOrElse(() => []),
      ws.getOrElse(() => []),
    ));
  }
}
