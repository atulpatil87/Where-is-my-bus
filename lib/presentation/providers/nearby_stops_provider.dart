import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/stop.dart';
import 'city_provider.dart';
import 'providers_setup.dart';

// ── Distance filter radius (metres) ──────────────────────────────────────────
final nearbyRadiusProvider = StateProvider<double>((ref) => 500);

// ── Nearby stops result ───────────────────────────────────────────────────────
final nearbyStopsProvider =
    FutureProvider.autoDispose<List<Stop>>((ref) async {
  final radius = ref.watch(nearbyRadiusProvider);
  final city = ref.watch(selectedCityProvider);
  if (city == null) return [];

  final useCase = ref.read(getNearbyStopsUseCaseProvider);
  final result = await useCase.call(
    cityId: city.id,
    radiusMeters: radius,
  );
  return result.fold(
    (f) => throw Exception((f as dynamic).message ?? f.toString()),
    (stops) => stops,
  );
});
