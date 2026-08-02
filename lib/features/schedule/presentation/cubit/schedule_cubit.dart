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
      (schedule) => emit(ScheduleLoaded(schedule)),
    );
  }
}
