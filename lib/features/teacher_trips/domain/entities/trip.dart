import 'package:equatable/equatable.dart';

enum TripType { pickup, dropoff }

enum TripStatus { notStarted, inProgress, completed }

extension TripTypeX on TripType {
  String get label => this == TripType.pickup ? 'اصطحاب' : 'إيصال';
}

extension TripStatusX on TripStatus {
  String get label {
    switch (this) {
      case TripStatus.notStarted:
        return 'لم تبدأ';
      case TripStatus.inProgress:
        return 'جارية';
      case TripStatus.completed:
        return 'منتهية';
    }
  }
}

TripType tripTypeFromString(String s) => s == 'dropoff' ? TripType.dropoff : TripType.pickup;

TripStatus tripStatusFromString(String s) {
  switch (s) {
    case 'in_progress':
      return TripStatus.inProgress;
    case 'completed':
      return TripStatus.completed;
    default:
      return TripStatus.notStarted;
  }
}

class GeoPoint extends Equatable {
  final double lat;
  final double lng;
  const GeoPoint({required this.lat, required this.lng});
  @override
  List<Object?> get props => [lat, lng];
}

class TripBus extends Equatable {
  final int id;
  final String name;
  const TripBus({required this.id, required this.name});
  @override
  List<Object?> get props => [id, name];
}

class TripStudent extends Equatable {
  final int id;
  final String name;
  final String? avatar;
  final double homeLat;
  final double homeLng;
  final int stopOrder;
  final int? etaMinutes;
  final DateTime? arrivedAt;

  const TripStudent({
    required this.id,
    required this.name,
    this.avatar,
    required this.homeLat,
    required this.homeLng,
    required this.stopOrder,
    this.etaMinutes,
    this.arrivedAt,
  });

  @override
  List<Object?> get props => [id, name, avatar, homeLat, homeLng, stopOrder, etaMinutes, arrivedAt];
}

class Trip extends Equatable {
  final int id;
  final String name;
  final TripType type;
  final TripStatus status;
  final TripBus bus;
  final double? totalDistanceKm;
  final int? totalDurationMinutes;
  final String? googleMapsUrl;
  final List<TripStudent> students;

  const Trip({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.bus,
    this.totalDistanceKm,
    this.totalDurationMinutes,
    this.googleMapsUrl,
    required this.students,
  });

  @override
  List<Object?> get props =>
      [id, name, type, status, bus, totalDistanceKm, totalDurationMinutes, googleMapsUrl, students];
}

class MyTripsData extends Equatable {
  final GeoPoint school;
  final List<Trip> trips;
  const MyTripsData({required this.school, required this.trips});
  @override
  List<Object?> get props => [school, trips];
}

class NextStop extends Equatable {
  final int studentId;
  final String name;
  final int distanceMeters;
  final bool notified;
  final bool arrived;

  const NextStop({
    required this.studentId,
    required this.name,
    required this.distanceMeters,
    required this.notified,
    required this.arrived,
  });

  @override
  List<Object?> get props => [studentId, name, distanceMeters, notified, arrived];
}

class LocationUpdateResult extends Equatable {
  final TripStatus tripStatus;
  final NextStop? nextStop;

  const LocationUpdateResult({required this.tripStatus, this.nextStop});

  @override
  List<Object?> get props => [tripStatus, nextStop];
}
