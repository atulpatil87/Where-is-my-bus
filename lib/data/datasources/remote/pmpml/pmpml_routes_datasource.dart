import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/pmpml_api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../models/pmpml/pmpml_route_model.dart';
import '../../../models/pmpml/pmpml_stop_model.dart';

/// Fetches static route + stop data from the Chartr routes API.
///
/// Results are cached in Hive for [PmpmlApiConstants.combinedDataCacheTtlSeconds]
/// so the app works offline after first load.
class PmpmlRoutesDataSource {
  final Dio _dio;

  PmpmlRoutesDataSource(this._dio);

  // ── Combined Data ─────────────────────────────────────────────────────────

  /// Returns all routes and stops for Pune in a single network call.
  /// Uses a local Hive cache (6h TTL) to avoid hammering the API.
  Future<({List<PmpmlRouteModel> routes, List<PmpmlStopModel> stops})>
      getCombinedData({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _readCache();
      if (cached != null) return cached;
    }

    try {
      final response = await _dio.get<dynamic>(PmpmlApiConstants.combinedData);
      final data = response.data;

      if (data == null) {
        throw const ServerException(message: 'Empty combined data response.');
      }

      final routes = _parseRoutes(data);
      final stops = _parseStops(data);

      _writeCache(data);
      return (routes: routes, stops: stops);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  // ── Nearby Stops ──────────────────────────────────────────────────────────

  Future<List<PmpmlStopModel>> getNearbyStops(
      double lat, double lng, double radiusMeters) async {
    try {
      final response = await _dio.get<dynamic>(
        PmpmlApiConstants.nearbyStops,
        queryParameters: {
          'lat': lat,
          'lng': lng,
          'radius': radiusMeters.toInt(),
        },
      );
      return _parseStopsFromList(response.data);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  // ── Nearest Stop ──────────────────────────────────────────────────────────

  Future<PmpmlStopModel?> getNearestStop(double lat, double lng) async {
    try {
      final response = await _dio.get<dynamic>(
        PmpmlApiConstants.nearestStop,
        queryParameters: {'lat': lat, 'lng': lng},
      );
      if (response.data == null) return null;
      if (response.data is List) {
        final list = response.data as List;
        if (list.isEmpty) return null;
        return PmpmlStopModel.fromJson(
            Map<String, dynamic>.from(list.first as Map));
      }
      if (response.data is Map) {
        return PmpmlStopModel.fromJson(
            Map<String, dynamic>.from(response.data as Map));
      }
      return null;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  // ── Cache helpers ─────────────────────────────────────────────────────────

  ({List<PmpmlRouteModel> routes, List<PmpmlStopModel> stops})? _readCache() {
    final box = Hive.box<String>(PmpmlApiConstants.hiveBoxUserPrefs);
    final tsStr = box.get(PmpmlApiConstants.keyCombinedDataCacheTs);
    final raw = box.get(PmpmlApiConstants.keyCombinedDataCache);
    if (tsStr == null || raw == null) return null;

    final ts = DateTime.tryParse(tsStr);
    if (ts == null) return null;
    final age = DateTime.now().difference(ts).inSeconds;
    if (age > PmpmlApiConstants.combinedDataCacheTtlSeconds) return null;

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      return (routes: _parseRoutes(data), stops: _parseStops(data));
    } catch (_) {
      return null;
    }
  }

  void _writeCache(dynamic data) {
    try {
      final box = Hive.box<String>(PmpmlApiConstants.hiveBoxUserPrefs);
      box.put(PmpmlApiConstants.keyCombinedDataCache, jsonEncode(data));
      box.put(PmpmlApiConstants.keyCombinedDataCacheTs,
          DateTime.now().toIso8601String());
    } catch (_) {
      // Non-fatal — cache write failure just means next run re-fetches
    }
  }

  // ── Parsing helpers ───────────────────────────────────────────────────────

  List<PmpmlRouteModel> _parseRoutes(dynamic data) {
    if (data is Map) {
      final rawRoutes =
          data['routes'] ?? data['data']?['routes'] ?? data['route_list'] ?? [];
      if (rawRoutes is List) {
        return rawRoutes
            .whereType<Map<String, dynamic>>()
            .map(PmpmlRouteModel.fromJson)
            .toList();
      }
    }
    if (data is List) {
      // Some endpoints return a plain list of routes
      return data
          .whereType<Map<String, dynamic>>()
          .map(PmpmlRouteModel.fromJson)
          .toList();
    }
    return [];
  }

  List<PmpmlStopModel> _parseStops(dynamic data) {
    if (data is Map) {
      final rawStops =
          data['stops'] ?? data['data']?['stops'] ?? data['stop_list'] ?? [];
      return _parseStopsFromList(rawStops);
    }
    return [];
  }

  List<PmpmlStopModel> _parseStopsFromList(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(PmpmlStopModel.fromJson)
        .toList();
  }

  // ── Error Handling ────────────────────────────────────────────────────────

  Never _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        throw const TimeoutException();
      case DioExceptionType.connectionError:
        throw const NetworkException();
      default:
        final status = e.response?.statusCode;
        if (status == 401) throw const UnauthorizedException();
        throw ServerException(
          message: e.response?.data?.toString() ?? e.message ?? 'Routes API error.',
          statusCode: status,
        );
    }
  }
}
