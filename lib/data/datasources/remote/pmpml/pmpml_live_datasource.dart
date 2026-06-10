import 'package:dio/dio.dart';
import '../../../../core/constants/pmpml_api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../models/pmpml/pmpml_live_bus_model.dart';

class PmpmlLiveDataSource {
  final Dio _dio;

  PmpmlLiveDataSource(this._dio);

  Future<List<PmpmlLiveBusModel>> getBusesOnRoute(String routeId) async {
    try {
      final response = await _dio.get<dynamic>(
        PmpmlApiConstants.busesOnRoute,
        queryParameters: {'route_id': routeId},
      );
      return _parseBuses(response.data);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Fetches live buses across many [routeIds] concurrently and merges the
  /// results into a single deduplicated list.
  ///
  /// The PMPML/Chartr backend only exposes a per-route live endpoint, so to
  /// mirror the official app's "all live buses near you" view we fan out a
  /// bounded number of requests at a time ([concurrency]). Individual route
  /// failures are ignored so one bad route never blanks the whole map.
  Future<List<PmpmlLiveBusModel>> getBusesOnRoutes(
    List<String> routeIds, {
    int concurrency = 6,
  }) async {
    final ids = routeIds.where((id) => id.isNotEmpty).toSet().toList();
    if (ids.isEmpty) return [];

    final merged = <String, PmpmlLiveBusModel>{};

    for (var i = 0; i < ids.length; i += concurrency) {
      final batch = ids.skip(i).take(concurrency);
      final results = await Future.wait(
        batch.map((id) async {
          try {
            return await getBusesOnRoute(id);
          } catch (_) {
            return const <PmpmlLiveBusModel>[];
          }
        }),
      );
      for (final buses in results) {
        for (final bus in buses) {
          // Dedupe by bus id; keep the freshest report.
          final existing = merged[bus.busId];
          if (existing == null ||
              bus.lastUpdated.isAfter(existing.lastUpdated)) {
            merged[bus.busId] = bus;
          }
        }
      }
    }

    return merged.values.toList();
  }

  Future<bool> getApiStatus() async {
    try {
      final response = await _dio.get<dynamic>(PmpmlApiConstants.liveStatus);
      return (response.statusCode ?? 0) < 300;
    } on DioException {
      return false;
    }
  }

  Future<int?> getEta(String busNumber, int stopIdx, String routeLongName) async {
    try {
      final response = await _dio.get<dynamic>(
          PmpmlApiConstants.eta(busNumber, stopIdx, routeLongName));
      final data = response.data;
      if (data is Map) {
        return (data['eta_minutes'] ?? data['eta'] ?? data['etaMinutes']) as int?;
      }
      return null;
    } on DioException {
      return null;
    }
  }

  List<PmpmlLiveBusModel> _parseBuses(dynamic data) {
    List<dynamic> raw = [];
    if (data is List) {
      raw = data;
    } else if (data is Map) {
      raw = (data['buses'] ?? data['data'] ?? data['vehicles'] ?? []) as List;
    }
    return raw
        .whereType<Map<String, dynamic>>()
        .map(PmpmlLiveBusModel.fromJson)
        .where((b) => !b.isStale)
        .toList();
  }

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
          message: e.response?.data?.toString() ?? e.message ?? 'Live data API error.',
          statusCode: status,
        );
    }
  }
}
