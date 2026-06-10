import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/route.dart';
import '../../domain/entities/stop.dart';
import 'city_provider.dart';
import 'providers_setup.dart';

// ── Route Finder form state ───────────────────────────────────────────────────
final routeFinderFormProvider =
    StateNotifierProvider<RouteFinderFormNotifier, RouteFinderForm>((ref) {
  return RouteFinderFormNotifier();
});

class RouteFinderForm {
  final Stop? fromStop;
  final Stop? toStop;
  final DateTime travelTime;
  final bool isUsingCurrentLocation;

  RouteFinderForm({
    this.fromStop,
    this.toStop,
    DateTime? travelTime,
    this.isUsingCurrentLocation = true,
  }) : travelTime = travelTime ?? DateTime.now();

  RouteFinderForm copyWith({
    Stop? fromStop,
    Stop? toStop,
    DateTime? travelTime,
    bool? isUsingCurrentLocation,
  }) {
    return RouteFinderForm(
      fromStop: fromStop ?? this.fromStop,
      toStop: toStop ?? this.toStop,
      travelTime: travelTime ?? this.travelTime,
      isUsingCurrentLocation:
          isUsingCurrentLocation ?? this.isUsingCurrentLocation,
    );
  }
}

class RouteFinderFormNotifier extends StateNotifier<RouteFinderForm> {
  RouteFinderFormNotifier() : super(RouteFinderForm());

  void setFromStop(Stop stop) =>
      state = state.copyWith(fromStop: stop, isUsingCurrentLocation: false);

  void setToStop(Stop stop) => state = state.copyWith(toStop: stop);

  void useCurrentLocation() =>
      state = state.copyWith(isUsingCurrentLocation: true, fromStop: null);

  void setTravelTime(DateTime time) =>
      state = state.copyWith(travelTime: time);

  void swap() {
    state = RouteFinderForm(
      fromStop: state.toStop,
      toStop: state.fromStop,
      travelTime: state.travelTime,
    );
  }
}

// ── Route search results ──────────────────────────────────────────────────────
final routeResultsProvider =
    FutureProvider.autoDispose<List<RouteResult>>((ref) async {
  final form = ref.watch(routeFinderFormProvider);
  if (form.fromStop == null || form.toStop == null) return [];

  final city = ref.watch(selectedCityProvider);
  if (city == null) return [];

  final useCase = ref.read(findRouteUseCaseProvider);
  final result = await useCase.call(
    cityId: city.id,
    fromStopId: form.fromStop!.id,
    toStopId: form.toStop!.id,
    travelTime: form.travelTime,
  );
  return result.fold(
    (f) => throw Exception((f as dynamic).message ?? f.toString()),
    (r) => r,
  );
});

// ── Stop autocomplete search ──────────────────────────────────────────────────
final stopSearchProvider =
    FutureProvider.family<List<Stop>, String>((ref, query) async {
  if (query.length < 2) return [];
  final city = ref.watch(selectedCityProvider);
  if (city == null) return [];

  final repo = ref.read(stopRepositoryProvider);
  final result = await repo.searchStops(city.id, query);
  return result.fold(
    (f) => throw Exception((f as dynamic).message ?? f.toString()),
    (stops) => stops,
  );
});
