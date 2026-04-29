/// Firestore and Realtime DB collection / path constants.
class FirebaseConstants {
  // Firestore collection names
  static const String collectionCities = 'cities';
  static const String collectionRoutes = 'routes';
  static const String collectionStops = 'stops';
  static const String collectionTimetables = 'timetables';
  static const String collectionUsers = 'users';
  static const String collectionTrips = 'trips';
  static const String collectionCrowdReports = 'crowd_reports';
  static const String collectionIncidentReports = 'incident_reports';

  // Realtime DB paths
  static const String rtdbLiveBuses = 'live_buses';
  static const String rtdbCityMetaSuffix = '_meta';

  // Storage paths
  static const String storageAvatars = 'avatars';

  // Firestore field names
  static const String fieldIsActive = 'isActive';
  static const String fieldCityId = 'cityId';
  static const String fieldRouteNumber = 'routeNumber';
  static const String fieldUpdatedAt = 'updatedAt';
  static const String fieldCreatedAt = 'createdAt';
  static const String fieldLastUpdated = 'lastUpdated';
  static const String fieldUserId = 'userId';
  static const String fieldReportedAt = 'reportedAt';
  static const String fieldExpiresAt = 'expiresAt';
  static const String fieldStatus = 'status';

  // FCM topic prefix
  static const String fcmTopicCityPrefix = 'city_';
}
