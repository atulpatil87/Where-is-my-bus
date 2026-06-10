/// PMPML / Chartr backend — base URLs, endpoint paths, and local storage keys.
class PmpmlApiConstants {
  PmpmlApiConstants._();

  // ── Base URLs ─────────────────────────────────────────────────────────────
  static const String baseTicketing = 'https://prod-pmpml-ticketing-api.chartr.in';
  static const String baseRoutes = 'https://prod-pmpml-routesapi.chartr.in';
  static const String baseLiveData = 'https://prod-pmpml-live-data-api.chartr.in';
  static const String baseDirections = 'https://prod-pmpml-directions.chartr.in';
  static const String baseSchedule = 'https://schedule-api.chartr.in';
  static const String basePis = 'https://prod-pmpml-pis.chartr.in';
  static const String baseUserRating = 'https://prod-pmpml-user-rating.chartr.in';

  // ── Auth ──────────────────────────────────────────────────────────────────
  /// POST /create/{mobile}  — send OTP
  static String sendOtp(String mobile) => '/create/$mobile';

  /// POST /verify/{mobile}  — verify OTP → returns tokens
  static String verifyOtp(String mobile) => '/verify/$mobile';

  /// POST /api/v1/init-user
  static const String initUser = '/api/v1/init-user';

  // ── Routes API ────────────────────────────────────────────────────────────
  /// GET /v1/get-combined-data  — all routes + stops
  static const String combinedData = '/v1/get-combined-data';

  /// GET /v1/get-nearby-stops?lat=&lng=&radius=
  static const String nearbyStops = '/v1/get-nearby-stops';

  /// GET /v2/get-nearest-stop?lat=&lng=
  static const String nearestStop = '/v2/get-nearest-stop';

  /// POST /v1/send-searches
  static const String sendSearches = '/v1/send-searches';

  // ── Live Bus Data ─────────────────────────────────────────────────────────
  /// GET /buses-on-route?route_id=
  static const String busesOnRoute = '/buses-on-route';

  /// GET /status
  static const String liveStatus = '/status';

  /// GET /api/v2/eta/{busNumber}/{stopIdx}/{routeLongName}
  static String eta(String busNumber, int stopIdx, String routeLongName) =>
      '/api/v2/eta/$busNumber/$stopIdx/$routeLongName';

  // ── Directions ────────────────────────────────────────────────────────────
  static const String directionsBusV1 = '/v1/get_directions_bus';
  static const String directionsBusV2 = '/v2/get_directions_bus';
  static const String directionsMetroV2 = '/v2/get_directions_metro';

  // ── Schedule ──────────────────────────────────────────────────────────────
  /// GET /schedules/pune/{routeNumber}
  static String schedule(String routeNumber) => '/schedules/pune/$routeNumber';

  /// GET /schedules/pune/{routeNumber}/{stopId}
  static String scheduleAtStop(String routeNumber, String stopId) =>
      '/schedules/pune/$routeNumber/$stopId';

  // ── Hive / SharedPrefs Keys ───────────────────────────────────────────────
  static const String hiveBoxUserPrefs = 'user_prefs';
  static const String keyAccessToken = 'pmpml_access_token';
  static const String keyRefreshToken = 'pmpml_refresh_token';
  static const String keyMobile = 'pmpml_mobile';
  static const String keyUserId = 'pmpml_user_id';
  static const String keyCombinedDataCache = 'pmpml_combined_data_cache';
  static const String keyCombinedDataCacheTs = 'pmpml_combined_data_cache_ts';

  // ── Config ────────────────────────────────────────────────────────────────
  static const String city = 'pune';
  static const int combinedDataCacheTtlSeconds = 21600; // 6 hours
  static const int livePollIntervalSeconds = 15;
  static const String platform = 'android';
  static const String appVersion = '1.0';

  // ── City-wide live view (all buses near you) ───────────────────────────────
  /// Max number of routes polled per refresh for the "buses near me" map view.
  /// Bounds the request fan-out so we never hammer the live-data API.
  static const int maxLiveRoutes = 30;

  /// Radius (metres) used to pick which routes count as "nearby" the user.
  static const double nearbyRoutesRadiusMeters = 2500;
}
