import 'dart:math' as math;

/// City boundary config for GPS-based city detection.
class CityConfig {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final double radiusKm;

  const CityConfig({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.radiusKm,
  });
}

class CityConstants {
  static const List<CityConfig> supportedCities = [
    CityConfig(id: 'pune', name: 'Pune', lat: 18.5204, lng: 73.8567, radiusKm: 40),
    CityConfig(id: 'mumbai', name: 'Mumbai', lat: 19.0760, lng: 72.8777, radiusKm: 50),
    CityConfig(id: 'delhi', name: 'Delhi', lat: 28.6139, lng: 77.2090, radiusKm: 60),
    CityConfig(id: 'bangalore', name: 'Bangalore', lat: 12.9716, lng: 77.5946, radiusKm: 45),
    CityConfig(id: 'hyderabad', name: 'Hyderabad', lat: 17.3850, lng: 78.4867, radiusKm: 45),
    CityConfig(id: 'chennai', name: 'Chennai', lat: 13.0827, lng: 80.2707, radiusKm: 45),
    CityConfig(id: 'ahmedabad', name: 'Ahmedabad', lat: 23.0225, lng: 72.5714, radiusKm: 40),
    CityConfig(id: 'kolkata', name: 'Kolkata', lat: 22.5726, lng: 88.3639, radiusKm: 45),
    CityConfig(id: 'jaipur', name: 'Jaipur', lat: 26.9124, lng: 75.7873, radiusKm: 40),
    CityConfig(id: 'nagpur', name: 'Nagpur', lat: 21.1458, lng: 79.0882, radiusKm: 35),
    CityConfig(id: 'surat', name: 'Surat', lat: 21.1702, lng: 72.8311, radiusKm: 35),
    CityConfig(id: 'indore', name: 'Indore', lat: 22.7196, lng: 75.8577, radiusKm: 35),
  ];

  /// Returns the first matching city config for the given GPS coordinates,
  /// or null if outside all city boundaries.
  static CityConfig? findByCoordinates(double lat, double lng) {
    for (final city in supportedCities) {
      final distance = _haversineKm(lat, lng, city.lat, city.lng);
      if (distance <= city.radiusKm) return city;
    }
    return null;
  }

  static double _haversineKm(
      double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.pow(math.sin(dLon / 2), 2);
    return earthRadius * 2 * math.asin(math.sqrt(a));
  }

  static double _toRad(double deg) => deg * math.pi / 180;
}
