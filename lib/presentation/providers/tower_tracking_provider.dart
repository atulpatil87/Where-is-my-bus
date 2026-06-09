import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/cell_tower.dart';
import 'providers_setup.dart';

/// A single poll of the no-GPS tracker: the raw serving cell plus, when the
/// tower is already mapped, the resolved [TowerFix].
class TowerSnapshot {
  final CellTower? cell;
  final TowerFix? fix;
  final String? error;

  const TowerSnapshot({this.cell, this.fix, this.error});

  bool get hasCell => cell != null;
  bool get isMapped => fix != null;
}

/// Streams the current cell tower and its resolved location for [cityId],
/// refreshing on [AppConstants.towerReadIntervalSecs]. Drives the live readout
/// card without ever requesting a GPS fix.
final towerSnapshotProvider =
    StreamProvider.family<TowerSnapshot, String>((ref, cityId) async* {
  final towerService = ref.watch(cellTowerServiceProvider);
  final resolveFix = ref.watch(resolveTowerFixUseCaseProvider);

  Future<TowerSnapshot> poll() async {
    try {
      final cell = await towerService.getPrimaryCell();
      if (cell == null) {
        return const TowerSnapshot(error: 'No serving cell tower detected.');
      }
      final fixResult = await resolveFix.call(cityId: cityId);
      return fixResult.fold(
        (f) => TowerSnapshot(cell: cell, error: f.message),
        (fix) => TowerSnapshot(cell: cell, fix: fix),
      );
    } catch (e) {
      return TowerSnapshot(error: e.toString());
    }
  }

  yield await poll();
  yield* Stream.periodic(
    const Duration(seconds: AppConstants.towerReadIntervalSecs),
  ).asyncMap((_) => poll());
});

/// Drives the "share my bus position via cell tower" toggle. Re-reads the
/// serving tower every [AppConstants.towerShareIntervalSecs] and republishes —
/// the GPS-free analogue of [BusSharingNotifier].
final towerSharingProvider =
    StateNotifierProvider<TowerSharingNotifier, TowerSharingState>((ref) {
  return TowerSharingNotifier(ref);
});

class TowerSharingState {
  final bool isSharing;
  final String? routeId;
  final TowerFix? lastFix;
  final String? error;

  const TowerSharingState({
    this.isSharing = false,
    this.routeId,
    this.lastFix,
    this.error,
  });

  TowerSharingState copyWith({
    bool? isSharing,
    String? routeId,
    TowerFix? lastFix,
    String? error,
    bool clearError = false,
  }) {
    return TowerSharingState(
      isSharing: isSharing ?? this.isSharing,
      routeId: routeId ?? this.routeId,
      lastFix: lastFix ?? this.lastFix,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class TowerSharingNotifier extends StateNotifier<TowerSharingState> {
  final Ref _ref;
  Timer? _timer;

  TowerSharingNotifier(this._ref) : super(const TowerSharingState());

  Future<void> start({
    required String cityId,
    required String routeId,
    required String routeNumber,
  }) async {
    state = state.copyWith(isSharing: true, routeId: routeId, clearError: true);
    await _publishOnce(cityId, routeId, routeNumber);
    _timer = Timer.periodic(
      const Duration(seconds: AppConstants.towerShareIntervalSecs),
      (_) => _publishOnce(cityId, routeId, routeNumber),
    );
  }

  Future<void> _publishOnce(
    String cityId,
    String routeId,
    String routeNumber,
  ) async {
    final useCase = _ref.read(shareBusLocationViaTowerUseCaseProvider);
    final result = await useCase.call(
      cityId: cityId,
      routeId: routeId,
      routeNumber: routeNumber,
    );
    if (!mounted) return;
    result.fold(
      (f) => state = state.copyWith(error: f.message),
      (fix) => state = state.copyWith(lastFix: fix, clearError: true),
    );
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    state = const TowerSharingState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
