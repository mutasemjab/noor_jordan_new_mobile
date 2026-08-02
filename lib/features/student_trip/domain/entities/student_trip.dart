import 'package:equatable/equatable.dart';

class BusLocation extends Equatable {
  final double lat;
  final double lng;
  final DateTime updatedAt;

  const BusLocation({required this.lat, required this.lng, required this.updatedAt});

  @override
  List<Object?> get props => [lat, lng, updatedAt];
}

class StudentTrip extends Equatable {
  final int id;
  final String type; // "pickup" | "dropoff"
  final String busName;
  final BusLocation? busLocation;
  final int myStopOrder;
  final int? myEtaMinutes;
  final DateTime? arrivedAtMe;

  const StudentTrip({
    required this.id,
    required this.type,
    required this.busName,
    this.busLocation,
    required this.myStopOrder,
    this.myEtaMinutes,
    this.arrivedAtMe,
  });

  @override
  List<Object?> get props => [id, type, busName, busLocation, myStopOrder, myEtaMinutes, arrivedAtMe];
}
