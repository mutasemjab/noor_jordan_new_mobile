import '../../domain/entities/trip.dart';

class GeoPointModel extends GeoPoint {
  const GeoPointModel({required super.lat, required super.lng});

  factory GeoPointModel.fromJson(Map<String, dynamic> json) => GeoPointModel(
        lat: (json['lat'] as num?)?.toDouble() ?? 0,
        lng: (json['lng'] as num?)?.toDouble() ?? 0,
      );
}

class TripBusModel extends TripBus {
  const TripBusModel({required super.id, required super.name});

  factory TripBusModel.fromJson(Map<String, dynamic> json) => TripBusModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '',
      );
}

class TripStudentModel extends TripStudent {
  const TripStudentModel({
    required super.id,
    required super.name,
    super.avatar,
    required super.homeLat,
    required super.homeLng,
    required super.stopOrder,
    super.etaMinutes,
    super.arrivedAt,
  });

  factory TripStudentModel.fromJson(Map<String, dynamic> json) {
    return TripStudentModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String?,
      homeLat: (json['home_lat'] as num?)?.toDouble() ?? 0,
      homeLng: (json['home_lng'] as num?)?.toDouble() ?? 0,
      stopOrder: (json['stop_order'] as num?)?.toInt() ?? 0,
      etaMinutes: (json['eta_minutes'] as num?)?.toInt(),
      arrivedAt: json['arrived_at'] != null ? DateTime.tryParse(json['arrived_at'] as String) : null,
    );
  }
}

class TripModel extends Trip {
  const TripModel({
    required super.id,
    required super.name,
    required super.type,
    required super.status,
    required super.bus,
    super.totalDistanceKm,
    super.totalDurationMinutes,
    super.googleMapsUrl,
    required super.students,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    final busJson = json['bus'] as Map<String, dynamic>? ?? {};
    final studentsJson = json['students'] as List<dynamic>? ?? [];
    return TripModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      type: tripTypeFromString(json['type'] as String? ?? 'pickup'),
      status: tripStatusFromString(json['status'] as String? ?? 'not_started'),
      bus: TripBusModel.fromJson(busJson),
      totalDistanceKm: (json['total_distance_km'] as num?)?.toDouble(),
      totalDurationMinutes: (json['total_duration_minutes'] as num?)?.toInt(),
      googleMapsUrl: json['google_maps_url'] as String?,
      students: studentsJson.whereType<Map<String, dynamic>>().map((e) => TripStudentModel.fromJson(e)).toList(),
    );
  }
}

class NextStopModel extends NextStop {
  const NextStopModel({
    required super.studentId,
    required super.name,
    required super.distanceMeters,
    required super.notified,
    required super.arrived,
  });

  factory NextStopModel.fromJson(Map<String, dynamic> json) => NextStopModel(
        studentId: (json['student_id'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '',
        distanceMeters: (json['distance_meters'] as num?)?.toInt() ?? 0,
        notified: json['notified'] as bool? ?? false,
        arrived: json['arrived'] as bool? ?? false,
      );
}

class LocationUpdateResultModel extends LocationUpdateResult {
  const LocationUpdateResultModel({required super.tripStatus, super.nextStop});

  factory LocationUpdateResultModel.fromJson(Map<String, dynamic> json) {
    final nextStopJson = json['next_stop'] as Map<String, dynamic>?;
    return LocationUpdateResultModel(
      tripStatus: tripStatusFromString(json['trip_status'] as String? ?? 'in_progress'),
      nextStop: nextStopJson != null ? NextStopModel.fromJson(nextStopJson) : null,
    );
  }
}
