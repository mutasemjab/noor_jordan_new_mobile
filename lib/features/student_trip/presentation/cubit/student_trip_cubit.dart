import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_my_trip_usecase.dart';
import 'student_trip_state.dart';

/// Backs both the one-shot "is there a trip today" check on the student home
/// page and the dedicated tracking screen's recurring poll — call [load] for
/// the former, [startPolling] for the latter (every 25s, only while the
/// tracking screen is open, per the backend's battery-saving guidance).
class StudentTripCubit extends Cubit<StudentTripState> {
  final GetMyTripUseCase _getMyTrip;
  Timer? _timer;

  StudentTripCubit(this._getMyTrip) : super(const StudentTripLoading());

  Future<void> load() async {
    final result = await _getMyTrip();
    result.fold(
      (f) => emit(StudentTripError(f.message)),
      (trip) => emit(StudentTripLoaded(trip)),
    );
  }

  void startPolling() {
    load();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 25), (_) => load());
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
