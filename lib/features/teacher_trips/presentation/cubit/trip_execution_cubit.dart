import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/trip.dart';
import '../../domain/usecases/teacher_trips_usecases.dart';
import '../../services/trip_location_service.dart';
import 'trip_execution_state.dart';

/// Drives the companion teacher's live trip screen: sends the device's
/// location every ~17s while the trip is running (foreground only — no
/// background service, matching the backend's own battery-saving note) and
/// surfaces the backend-computed next stop after each ping.
class TripExecutionCubit extends Cubit<TripExecutionState> {
  final SendTripLocationUseCase _sendLocation;
  final MarkTripStudentArrivedUseCase _markArrived;
  final CompleteTripUseCase _completeTrip;
  final TripLocationService _locationService;

  final Trip trip;
  Timer? _timer;

  TripExecutionCubit({
    required this.trip,
    required SendTripLocationUseCase sendLocation,
    required MarkTripStudentArrivedUseCase markArrived,
    required CompleteTripUseCase completeTrip,
    required TripLocationService locationService,
  })  : _sendLocation = sendLocation,
        _markArrived = markArrived,
        _completeTrip = completeTrip,
        _locationService = locationService,
        super(TripExecutionActive(
          trip: trip,
          arrivedStudentIds: trip.students.where((s) => s.arrivedAt != null).map((s) => s.id).toSet(),
        )) {
    _startLoop();
  }

  void _startLoop() {
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 17), (_) => _tick());
  }

  Future<void> _tick() async {
    final current = state;
    if (current is! TripExecutionActive) return;
    final hasPermission = await _locationService.ensurePermission();
    if (!hasPermission) {
      _timer?.cancel();
      emit(const TripExecutionError('يرجى تفعيل صلاحية الموقع لمتابعة الجولة'));
      return;
    }
    try {
      final position = await _locationService.getCurrentPosition();
      final result = await _sendLocation(tripId: trip.id, lat: position.latitude, lng: position.longitude);
      result.fold(
        (f) {
          _timer?.cancel();
          emit(TripExecutionError(f.message));
        },
        (update) {
          String? toast;
          var arrivedIds = current.arrivedStudentIds;
          if (update.nextStop?.arrived == true) {
            toast = 'وصلنا إلى ${update.nextStop!.name} ✅';
            arrivedIds = {...arrivedIds, update.nextStop!.studentId};
          } else if (update.nextStop?.notified == true) {
            toast = 'تم تنبيه ${update.nextStop!.name} ✅';
          }
          emit(current.copyWith(nextStop: update.nextStop, toastMessage: toast, arrivedStudentIds: arrivedIds));
        },
      );
    } catch (_) {
      // Swallow a single bad GPS reading — retry on the next tick rather
      // than interrupting the whole trip over a transient error.
    }
  }

  Future<String?> markArrivedManually(int studentId) async {
    final result = await _markArrived(tripId: trip.id, studentId: studentId);
    return result.fold((f) => f.message, (_) {
      final current = state;
      if (current is TripExecutionActive) {
        emit(current.copyWith(arrivedStudentIds: {...current.arrivedStudentIds, studentId}));
      }
      return null;
    });
  }

  Future<String?> complete() async {
    _timer?.cancel();
    final result = await _completeTrip(trip.id);
    return result.fold((f) => f.message, (_) {
      emit(const TripExecutionCompleted());
      return null;
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
