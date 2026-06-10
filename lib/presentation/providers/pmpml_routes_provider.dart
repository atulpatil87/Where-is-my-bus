import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/pmpml/pmpml_route_model.dart';
import '../../data/models/pmpml/pmpml_stop_model.dart';
import 'pmpml_providers_setup.dart';

// ── Routes provider ───────────────────────────────────────────────────────────

final pmpmlRoutesProvider =
    AsyncNotifierProvider<_PmpmlRoutesNotifier, List<PmpmlRouteModel>>(
  _PmpmlRoutesNotifier.new,
);

class _PmpmlRoutesNotifier extends AsyncNotifier<List<PmpmlRouteModel>> {
  @override
  Future<List<PmpmlRouteModel>> build() => _fetch();

  Future<List<PmpmlRouteModel>> _fetch({bool forceRefresh = false}) async {
    final repo = ref.read(pmpmlRepositoryProvider);
    final result = await repo.getRoutes(forceRefresh: forceRefresh);
    return result.fold((f) => throw Exception(f.message), (r) => r);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(forceRefresh: true));
  }
}

// ── Stops provider ────────────────────────────────────────────────────────────

final pmpmlStopsProvider =
    AsyncNotifierProvider<_PmpmlStopsNotifier, List<PmpmlStopModel>>(
  _PmpmlStopsNotifier.new,
);

class _PmpmlStopsNotifier extends AsyncNotifier<List<PmpmlStopModel>> {
  @override
  Future<List<PmpmlStopModel>> build() => _fetch();

  Future<List<PmpmlStopModel>> _fetch({bool forceRefresh = false}) async {
    final repo = ref.read(pmpmlRepositoryProvider);
    final result = await repo.getStops(forceRefresh: forceRefresh);
    return result.fold((f) => throw Exception(f.message), (r) => r);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(forceRefresh: true));
  }
}

// ── Stop search (derived) ─────────────────────────────────────────────────────

final pmpmlStopSearchProvider =
    Provider.family<List<PmpmlStopModel>, String>((ref, query) {
  final stopsAsync = ref.watch(pmpmlStopsProvider);
  return stopsAsync.when(
    data: (stops) {
      if (query.trim().isEmpty) return stops.take(20).toList();
      final q = query.toLowerCase();
      return stops
          .where((s) => s.stopName.toLowerCase().contains(q))
          .take(20)
          .toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// ── Route search (derived) ────────────────────────────────────────────────────

final pmpmlRouteSearchProvider =
    Provider.family<List<PmpmlRouteModel>, String>((ref, query) {
  final routesAsync = ref.watch(pmpmlRoutesProvider);
  return routesAsync.when(
    data: (routes) {
      if (query.trim().isEmpty) return routes.take(20).toList();
      final q = query.toLowerCase();
      return routes
          .where((r) =>
              r.routeNumber.toLowerCase().contains(q) ||
              r.routeLongName.toLowerCase().contains(q))
          .take(20)
          .toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
