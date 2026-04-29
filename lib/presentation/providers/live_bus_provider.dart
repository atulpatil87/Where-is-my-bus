import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/bus.dart';
import '../../domain/usecases/bus/get_live_buses_usecase.dart';
import 'providers_setup.dart';

// ── Bus filter state ─────────────────────────────────────────────────────────
final busFilterProvider = StateProvider<BusFilter>((ref) => BusFilter.empty);

// ── Live buses stream for selected city ──────────────────────────────────────
final liveBusesProvider =
    StreamProvider.family<List<Bus>, String>((ref, cityId) {
  final useCase = ref.read(getLiveBusesUseCaseProvider);
  final filter = ref.watch(busFilterProvider);
  return useCase
      .call(cityId: cityId, filter: filter)
      .map((each) => each.fold(
            (f) => throw Exception((f as dynamic).message ?? f.toString()),
            (buses) => buses,
          ));
});

// ── Selected bus for bottom sheet ─────────────────────────────────────────────
final selectedBusProvider = StateProvider<Bus?>((ref) => null);

// ── Bus sharing feature ───────────────────────────────────────────────────────
final isSharingLocationProvider =
    StateNotifierProvider<BusSharingNotifier, bool>((ref) {
  return BusSharingNotifier(ref);
});

class BusSharingNotifier extends StateNotifier<bool> {
  final Ref _ref;
  Timer? _shareTimer;

  BusSharingNotifier(this._ref) : super(false);

  void startSharing(String routeId) {
    state = true;
    _shareTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) async {
        final useCase = _ref.read(shareBusLocationUseCaseProvider);
        final location =
            await _ref.read(locationServiceProvider).getCurrentLocation();
        await useCase.call(
          routeId: routeId,
          lat: location.latitude,
          lng: location.longitude,
          heading: 0.0,
          speedKmh: location.speed * 3.6,
        );
      },
    );
  }

  void stopSharing() {
    state = false;
    _shareTimer?.cancel();
    _shareTimer = null;
  }

  @override
  void dispose() {
    _shareTimer?.cancel();
    super.dispose();
  }
}
