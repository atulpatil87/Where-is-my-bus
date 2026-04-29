/// Application-wide constants for API timeouts, pagination, etc.
class AppConstants {
  // Network timeouts
  static const int connectTimeoutMs = 10000;
  static const int receiveTimeoutMs = 15000;
  static const int sendTimeoutMs = 10000;

  // Retry policy
  static const int maxRetries = 2;
  static const int retryDelay1Secs = 1;
  static const int retryDelay2Secs = 3;

  // Cache TTLs (seconds)
  static const int cacheTtlCities = 86400; // 24h
  static const int cacheTtlRoutes = 21600; // 6h
  static const int cacheTtlStops = 21600; // 6h
  static const int cacheTtlTimetables = 43200; // 12h

  // Live bus
  static const int liveBusStaleThresholdSecs = 180; // 3 min
  static const int communityShareIntervalSecs = 15;
  static const int communityBusExpirySecs = 300; // 5 min

  // Crowd reports
  static const int crowdReportExpiryMins = 20;
  static const int crowdReportCooldownMins = 5;
  static const int crowdReportPoints = 5;
  static const int locationSharePoints = 2;

  // Nearby stops
  static const double defaultNearbyRadiusMeters = 500;
  static const double maxNearbyRadiusMeters = 2000;
  static const double walkingSpeedMetersPerMin = 80;

  // Route finding
  static const int maxRouteChanges = 2;

  // Geolocation
  static const int locationTimeoutSecs = 10;
  static const double locationDistanceFilter = 10; // metres

  // Min speed to be considered on a bus (km/h)
  static const double minBusSpeedKmh = 5.0;
}
