import 'package:equatable/equatable.dart';
import '../../domain/entities/attendance.dart';

abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {
  const AttendanceInitial();
}

class AttendanceLoading extends AttendanceState {
  const AttendanceLoading();
}

class AttendanceLoaded extends AttendanceState {
  final AttendanceData data;
  final DateTime? selectedDate;

  const AttendanceLoaded({
    required this.data,
    this.selectedDate,
  });

  List<AttendanceRecord> get recordsForSelectedDate {
    if (selectedDate == null) return [];
    return data.records.where((r) {
      return r.date.year == selectedDate!.year &&
          r.date.month == selectedDate!.month &&
          r.date.day == selectedDate!.day;
    }).toList();
  }

  AttendanceLoaded copyWith({
    AttendanceData? data,
    Object? selectedDate = _sentinel,
  }) {
    return AttendanceLoaded(
      data: data ?? this.data,
      selectedDate: selectedDate == _sentinel
          ? this.selectedDate
          : selectedDate as DateTime?,
    );
  }

  @override
  List<Object?> get props => [data, selectedDate];
}

class AttendanceError extends AttendanceState {
  final String message;

  const AttendanceError(this.message);

  @override
  List<Object?> get props => [message];
}

const Object _sentinel = Object();
