import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_schedule_usecase.dart';
import 'schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final GetScheduleUseCase _getSchedule;

  ScheduleCubit({required GetScheduleUseCase getSchedule})
      : _getSchedule = getSchedule,
        super(const ScheduleInitial());

  Future<void> load() async {
    emit(const ScheduleLoading());
    final result = await _getSchedule();
    result.fold(
      (failure) => emit(ScheduleError(failure.message)),
      (schedule) {
        final todayIndex = _getTodayIndex(schedule
            .map((d) => d.day)
            .toList());
        emit(ScheduleLoaded(schedule, selectedDayIndex: todayIndex));
      },
    );
  }

  void selectDay(int index) {
    final current = state;
    if (current is ScheduleLoaded) {
      emit(current.copyWith(selectedDayIndex: index));
    }
  }

  int _getTodayIndex(List<String> days) {
    const weekdayToKey = {
      1: 'monday',
      2: 'tuesday',
      3: 'wednesday',
      4: 'thursday',
      5: 'friday',
      6: 'saturday',
      7: 'sunday',
    };
    final todayKey = weekdayToKey[DateTime.now().weekday] ?? '';
    final index = days.indexWhere(
      (d) => d.toLowerCase() == todayKey,
    );
    return index >= 0 ? index : 0;
  }
}
