import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../constants/app_constants.dart';
import '../constants/city_constants.dart';

/// Service for GPS location acquisition and city detection.
class LocationService {
  /// One-time location fetch with permission checks.
  Future<Position> getCurrentLocation() async {
    final hasPermission = await _checkAndRequestPermission();
    if (!hasPermission) {
      final status = await Geolocator.checkPermission();
      if (status == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied.');
      }
      throw Exception('Location permission denied.');
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: AppConstants.locationTimeoutSecs),
    );
  }

  /// Continuous position stream — used when user opts in to share.
  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: AppConstants.locationDistanceFilter.toInt(),
      ),
    );
  }

  /// Detects which BusIndia city the user is in.
  /// Returns cityId or null if outside all service areas.
  String? detectCity(double lat, double lng) {
    final config = CityConstants.findByCoordinates(lat, lng);
    return config?.id;
  }

  /// Returns estimated walking minutes for a given distance in metres.
  int getWalkingMins(double distanceMeters) =>
      (distanceMeters / AppConstants.walkingSpeedMetersPerMin).ceil();

  Future<bool> _checkAndRequestPermission() async {
    var status = await Geolocator.checkPermission();
    if (status == LocationPermission.denied) {
      status = await Geolocator.requestPermission();
    }
    return status == LocationPermission.always ||
        status == LocationPermission.whileInUse;
  }
}
