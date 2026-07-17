import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_attendance_usecase.dart';
import 'attendance_state.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  final GetAttendanceUseCase _getAttendanceUseCase;

  AttendanceCubit(this._getAttendanceUseCase)
      : super(const AttendanceInitial());

  Future<void> load() async {
    emit(const AttendanceLoading());
    final result = await _getAttendanceUseCase();
    result.fold(
      (failure) => emit(AttendanceError(failure.message)),
      (data) => emit(AttendanceLoaded(data: data)),
    );
  }

  void selectDate(DateTime date) {
    final current = state;
    if (current is AttendanceLoaded) {
      final isSameDay = current.selectedDate != null &&
          current.selectedDate!.year == date.year &&
          current.selectedDate!.month == date.month &&
          current.selectedDate!.day == date.day;
      if (isSameDay) {
        emit(current.copyWith(selectedDate: null));
      } else {
        emit(current.copyWith(selectedDate: date));
      }
    }
  }
}
