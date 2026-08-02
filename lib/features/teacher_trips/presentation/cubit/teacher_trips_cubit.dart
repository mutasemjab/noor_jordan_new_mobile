import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/trip.dart';
import '../../domain/usecases/teacher_trips_usecases.dart';
import 'teacher_trips_state.dart';

class TeacherTripsCubit extends Cubit<TeacherTripsState> {
  final GetMyTripsUseCase _getMyTrips;
  final StartTripUseCase _startTrip;

  TeacherTripsCubit({
    required GetMyTripsUseCase getMyTrips,
    required StartTripUseCase startTrip,
  })  : _getMyTrips = getMyTrips,
        _startTrip = startTrip,
        super(const TeacherTripsLoading());

  Future<void> load() async {
    emit(const TeacherTripsLoading());
    final result = await _getMyTrips();
    result.fold(
      (f) => emit(TeacherTripsError(f.message)),
      (data) => emit(TeacherTripsLoaded(school: data.school, trips: data.trips)),
    );
  }

  /// Starts the trip and returns it on success, or an error message.
  Future<({Trip? trip, String? error})> start(int tripId) async {
    final result = await _startTrip(tripId);
    return result.fold(
      (f) => (trip: null, error: f.message),
      (trip) => (trip: trip, error: null),
    );
  }
}
