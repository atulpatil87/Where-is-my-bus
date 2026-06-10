import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/stop.dart';
import 'bluetooth_location_provider.dart';
import 'city_provider.dart';
import 'providers_setup.dart';

// ── Distance filter radius (metres) ──────────────────────────────────────────
final nearbyRadiusProvider = StateProvider<double>((ref) => 500);

// ── Nearby stops result ───────────────────────────────────────────────────────
// Uses the effective location (GPS, falling back to a nearby Bluetooth
// peer's broadcast position when GPS is unavailable) so stops keep showing
// up even with GPS off, as long as another BusIndia user is in range.
final nearbyStopsProvider =
    FutureProvider.autoDispose<List<Stop>>((ref) async {
  final radius = ref.watch(nearbyRadiusProvider);
  final city = ref.watch(selectedCityProvider);
  if (city == null) return [];

  final locationFix = await ref.watch(effectiveLocationProvider.future);

  final useCase = ref.read(getNearbyStopsUseCaseProvider);
  final result = await useCase.call(
    cityId: city.id,
    radiusMeters: radius,
    lat: locationFix.lat,
    lng: locationFix.lng,
  );
  return result.fold(
    (f) => throw Exception((f as dynamic).message ?? f.toString()),
    (stops) => stops,
  );
});
