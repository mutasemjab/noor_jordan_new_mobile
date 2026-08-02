import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_exam_schedules_usecase.dart';
import 'exam_schedules_state.dart';

class ExamSchedulesCubit extends Cubit<ExamSchedulesState> {
  final GetExamSchedulesUseCase _getExamSchedules;

  ExamSchedulesCubit(this._getExamSchedules) : super(const ExamSchedulesInitial());

  Future<void> load() async {
    emit(const ExamSchedulesLoading());
    final result = await _getExamSchedules();
    result.fold(
      (failure) => emit(ExamSchedulesError(failure.message)),
      (items) => emit(ExamSchedulesLoaded(items)),
    );
  }
}
