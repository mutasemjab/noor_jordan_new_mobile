import 'package:geolocator/geolocator.dart';

/// Thin wrapper around geolocator for the companion-teacher trip flow.
/// Tracking only runs while the trip execution screen is open (foreground) —
/// no background service, matching the backend's own battery-saving note.
class TripLocationService {
  Future<bool> ensurePermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return false;
    }
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<Position> getCurrentPosition() {
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }
}
