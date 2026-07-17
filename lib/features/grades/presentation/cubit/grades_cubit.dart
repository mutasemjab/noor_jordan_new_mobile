import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_grades_usecase.dart';
import 'grades_state.dart';

class GradesCubit extends Cubit<GradesState> {
  final GetGradesUseCase _getGradesUseCase;

  GradesCubit(this._getGradesUseCase) : super(const GradesInitial());

  Future<void> load() async {
    emit(const GradesLoading());
    final result = await _getGradesUseCase();
    result.fold(
      (failure) => emit(GradesError(failure.message)),
      (grades) => emit(GradesLoaded(grades: grades)),
    );
  }

  void filterBySubject(String? subjectId) {
    final current = state;
    if (current is GradesLoaded) {
      emit(current.copyWith(selectedFilter: subjectId));
    }
  }
}
