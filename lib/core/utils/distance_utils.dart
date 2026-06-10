import 'dart:math' as math;

/// Haversine distance calculation and related geo utilities.
class DistanceUtils {
  static const double _earthRadiusKm = 6371.0;

  /// Returns distance in metres between two lat/lng points.
  static double haversineMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.pow(math.sin(dLon / 2), 2);
    final c = 2 * math.asin(math.sqrt(a));
    return _earthRadiusKm * c * 1000; // convert km → metres
  }

  /// Returns distance in kilometres.
  static double haversineKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) =>
      haversineMeters(lat1, lon1, lat2, lon2) / 1000;

  /// Walking time estimate based on 80 m/min average walking speed.
  static int walkingMins(double distanceMeters) =>
      (distanceMeters / 80).ceil();

  /// Human-readable distance string: "350m" or "1.2 km".
  static String formatDistance(double meters) {
    if (meters < 1000) return '${meters.toInt()}m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  static double _toRad(double deg) => deg * math.pi / 180;
}
