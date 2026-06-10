import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/pmpml/pmpml_direction_model.dart';
import '../../data/models/pmpml/pmpml_stop_model.dart';
import 'pmpml_providers_setup.dart';

// ── Selected stops for route finder ──────────────────────────────────────────

final fromStopProvider = StateProvider<PmpmlStopModel?>((ref) => null);
final toStopProvider = StateProvider<PmpmlStopModel?>((ref) => null);

// ── Directions state ──────────────────────────────────────────────────────────

class PmpmlDirectionsState {
  final bool isLoading;
  final PmpmlDirectionModel? result;
  final String? errorMessage;

  const PmpmlDirectionsState({
    this.isLoading = false,
    this.result,
    this.errorMessage,
  });

  bool get hasResult => result != null;
  bool get hasError => errorMessage != null;

  PmpmlDirectionsState copyWith({
    bool? isLoading,
    PmpmlDirectionModel? result,
    String? errorMessage,
  }) =>
      PmpmlDirectionsState(
        isLoading: isLoading ?? this.isLoading,
        result: result ?? this.result,
        errorMessage: errorMessage,
      );
}

class PmpmlDirectionsNotifier extends StateNotifier<PmpmlDirectionsState> {
  final Ref _ref;

  PmpmlDirectionsNotifier(this._ref) : super(const PmpmlDirectionsState());

  Future<void> findRoute() async {
    final from = _ref.read(fromStopProvider);
    final to = _ref.read(toStopProvider);

    if (from == null || to == null) {
      state = const PmpmlDirectionsState(
          errorMessage: 'Please select both From and To stops.');
      return;
    }

    state = const PmpmlDirectionsState(isLoading: true);
    final repo = _ref.read(pmpmlRepositoryProvider);
    final result = await repo.getBusDirections(
      fromLat: from.lat,
      fromLng: from.lng,
      toLat: to.lat,
      toLng: to.lng,
    );
    result.fold(
      (f) => state = PmpmlDirectionsState(errorMessage: f.message),
      (d) => state = PmpmlDirectionsState(result: d),
    );
  }

  void clear() => state = const PmpmlDirectionsState();
}

final pmpmlDirectionsProvider =
    StateNotifierProvider<PmpmlDirectionsNotifier, PmpmlDirectionsState>(
  (ref) => PmpmlDirectionsNotifier(ref),
);
