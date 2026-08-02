import '../../domain/entities/student_trip.dart';

class BusLocationModel extends BusLocation {
  const BusLocationModel({required super.lat, required super.lng, required super.updatedAt});

  factory BusLocationModel.fromJson(Map<String, dynamic> json) => BusLocationModel(
        lat: (json['lat'] as num?)?.toDouble() ?? 0,
        lng: (json['lng'] as num?)?.toDouble() ?? 0,
        updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
      );
}

class StudentTripModel extends StudentTrip {
  const StudentTripModel({
    required super.id,
    required super.type,
    required super.busName,
    super.busLocation,
    required super.myStopOrder,
    super.myEtaMinutes,
    super.arrivedAtMe,
  });

  factory StudentTripModel.fromJson(Map<String, dynamic> json) {
    final busLocationJson = json['bus_location'] as Map<String, dynamic>?;
    return StudentTripModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: json['type'] as String? ?? 'pickup',
      busName: json['bus_name'] as String? ?? '',
      busLocation: busLocationJson != null ? BusLocationModel.fromJson(busLocationJson) : null,
      myStopOrder: (json['my_stop_order'] as num?)?.toInt() ?? 0,
      myEtaMinutes: (json['my_eta_minutes'] as num?)?.toInt(),
      arrivedAtMe: json['arrived_at_me'] != null ? DateTime.tryParse(json['arrived_at_me'] as String) : null,
    );
  }
}
