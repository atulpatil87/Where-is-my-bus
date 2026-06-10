import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/pmpml_api_constants.dart';
import '../../data/models/pmpml/pmpml_live_bus_model.dart';
import '../../data/models/pmpml/pmpml_route_model.dart';
import 'pmpml_routes_provider.dart';
import 'pmpml_providers_setup.dart';

/// Selected route ID for the live map screen.
final selectedRouteIdProvider = StateProvider<String?>((ref) => null);

/// The user's last known position, used to prioritise which routes the
/// city-wide live view polls. `null` until location is resolved.
final userLatLngProvider =
    StateProvider<({double lat, double lng})?>((ref) => null);

/// Polling-based live buses for a single [routeId].
/// Returns empty list if [routeId] is null (no filter selected).
final pmpmlLiveBusesProvider =
    FutureProvider.family<List<PmpmlLiveBusModel>, String>((ref, routeId) async {
  final repo = ref.watch(pmpmlRepositoryProvider);
  final result = await repo.getLiveBuses(routeId);
  return result.fold((f) => throw Exception(f.message), (r) => r);
});

/// Live buses for the currently selected route, auto-polling every 15s via
/// [AsyncValue.refresh]. The screen calls [ref.invalidate] on a Timer.
final pmpmlAllLiveBusesProvider =
    FutureProvider<List<PmpmlLiveBusModel>>((ref) async {
  final routeId = ref.watch(selectedRouteIdProvider);
  if (routeId == null || routeId.isEmpty) return [];
  final repo = ref.watch(pmpmlRepositoryProvider);
  final result = await repo.getLiveBuses(routeId);
  return result.fold((f) => throw Exception(f.message), (r) => r);
});

/// City-wide "all live buses near you" view that mirrors the official PMPML
/// app: shows every live bus across the routes around the user, with no route
/// selection or login required.
///
/// When the user's location is known we poll the routes serving stops within
/// [PmpmlApiConstants.nearbyRoutesRadiusMeters]; otherwise we fall back to the
/// first [PmpmlApiConstants.maxLiveRoutes] routes. The set is always capped to
/// bound the request fan-out.
final cityLiveBusesProvider =
    AsyncNotifierProvider<CityLiveBusesNotifier, List<PmpmlLiveBusModel>>(
  CityLiveBusesNotifier.new,
);

class CityLiveBusesNotifier extends AsyncNotifier<List<PmpmlLiveBusModel>> {
  @override
  Future<List<PmpmlLiveBusModel>> build() async {
    // Rebuild whenever the user's location changes so the nearby-route set
    // tracks them.
    final user = ref.watch(userLatLngProvider);
    final routes = await ref.watch(pmpmlRoutesProvider.future);
    if (routes.isEmpty) return const [];

    final routeIds = _selectRouteIds(routes, user);
    final repo = ref.watch(pmpmlRepositoryProvider);
    final result = await repo.getLiveBusesForRoutes(routeIds);
    return result.fold((f) => throw Exception(f.message), (r) => r);
  }

  /// Re-polls live positions for the current route set. Riverpod keeps the
  /// previous list available via [AsyncValue.valueOrNull] while reloading, so
  /// the map doesn't blank out between refreshes.
  void refresh() => ref.invalidateSelf();

  List<String> _selectRouteIds(
    List<PmpmlRouteModel> routes,
    ({double lat, double lng})? user,
  ) {
    List<String> firstN() => routes
        .take(PmpmlApiConstants.maxLiveRoutes)
        .map((r) => r.routeId)
        .where((id) => id.isNotEmpty)
        .toList();

    if (user == null) return firstN();

    final stops = ref.read(pmpmlStopsProvider).valueOrNull ?? const [];
    if (stops.isEmpty) return firstN();

    // Collect route ids served by stops within the nearby radius.
    final nearbyRouteIds = <String>{};
    for (final stop in stops) {
      if (stop.lat == 0 && stop.lng == 0) continue;
      final d = _distanceMeters(user.lat, user.lng, stop.lat, stop.lng);
      if (d <= PmpmlApiConstants.nearbyRoutesRadiusMeters) {
        nearbyRouteIds.addAll(stop.routeIds);
      }
    }

    if (nearbyRouteIds.isEmpty) return firstN();

    final selected = routes
        .where((r) => nearbyRouteIds.contains(r.routeId))
        .map((r) => r.routeId)
        .where((id) => id.isNotEmpty)
        .take(PmpmlApiConstants.maxLiveRoutes)
        .toList();

    return selected.isEmpty ? firstN() : selected;
  }

  /// Haversine great-circle distance in metres.
  double _distanceMeters(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371000.0; // metres
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return earthRadius * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double _toRad(double deg) => deg * math.pi / 180.0;
}
