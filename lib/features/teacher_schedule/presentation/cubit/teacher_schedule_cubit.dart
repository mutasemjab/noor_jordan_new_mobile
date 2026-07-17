import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_teacher_schedule_usecase.dart';
import 'teacher_schedule_state.dart';

class TeacherScheduleCubit extends Cubit<TeacherScheduleState> {
  final GetTeacherScheduleUseCase _useCase;
  TeacherScheduleCubit(this._useCase) : super(TeacherScheduleInitial());

  Future<void> load() async {
    emit(TeacherScheduleLoading());
    final result = await _useCase();
    result.fold(
      (f) => emit(TeacherScheduleError(f.message)),
      (schedule) {
        final todayIndex = _getTodayIndex(schedule);
        emit(TeacherScheduleLoaded(schedule, selectedDayIndex: todayIndex));
      },
    );
  }

  void selectDay(int index) {
    final current = state;
    if (current is TeacherScheduleLoaded) {
      emit(TeacherScheduleLoaded(current.schedule, selectedDayIndex: index));
    }
  }

  int _getTodayIndex(List<dynamic> schedule) {
    final today = DateTime.now().weekday;
    const dayMap = {1: 'monday', 2: 'tuesday', 3: 'wednesday', 4: 'thursday', 5: 'friday', 6: 'saturday', 7: 'sunday'};
    final todayName = dayMap[today] ?? '';
    for (int i = 0; i < schedule.length; i++) {
      if (schedule[i].day.toLowerCase() == todayName) return i;
    }
    return 0;
  }
}
