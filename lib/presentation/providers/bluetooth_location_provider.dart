import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/bluetooth_peer.dart';
import '../../domain/entities/location_fix.dart';
import '../../domain/usecases/bluetooth/start_bluetooth_location_usecase.dart';
import '../../domain/usecases/bluetooth/stop_bluetooth_location_usecase.dart';
import '../../domain/usecases/bluetooth/get_bluetooth_derived_location_usecase.dart';
import 'providers_setup.dart';

// ── State ─────────────────────────────────────────────────────────────────────

enum BluetoothMeshStatus { idle, starting, active, error }

class BluetoothMeshState {
  final BluetoothMeshStatus status;
  final List<BluetoothPeer> peers;
  final String? errorMessage;

  const BluetoothMeshState({
    this.status = BluetoothMeshStatus.idle,
    this.peers = const [],
    this.errorMessage,
  });

  BluetoothMeshState copyWith({
    BluetoothMeshStatus? status,
    List<BluetoothPeer>? peers,
    String? errorMessage,
  }) {
    return BluetoothMeshState(
      status: status ?? this.status,
      peers: peers ?? this.peers,
      errorMessage: errorMessage,
    );
  }

  bool get isActive => status == BluetoothMeshStatus.active;
  bool get hasError => status == BluetoothMeshStatus.error;
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class BluetoothMeshNotifier extends StateNotifier<BluetoothMeshState> {
  final StartBluetoothLocationUseCase _start;
  final StopBluetoothLocationUseCase _stop;
  final GetBluetoothDerivedLocationUseCase _getDerived;
  final Ref _ref;

  StreamSubscription<List<BluetoothPeer>>? _peerSub;

  BluetoothMeshNotifier(
    this._start,
    this._stop,
    this._getDerived,
    this._ref,
  ) : super(const BluetoothMeshState());

  /// Start advertising own location + scanning for peers.
  Future<void> start({double? fallbackLat, double? fallbackLng}) async {
    if (state.isActive) return;
    state = state.copyWith(status: BluetoothMeshStatus.starting);

    final result = await _start.call(
      fallbackLat: fallbackLat,
      fallbackLng: fallbackLng,
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: BluetoothMeshStatus.error,
        errorMessage: failure.message,
      ),
      (_) {
        state = state.copyWith(status: BluetoothMeshStatus.active);
        _subscribeToPeers();
        // Refresh advertised location every 20 seconds.
        _scheduleLocationRefresh();
      },
    );
  }

  /// Stop all BLE mesh activity.
  Future<void> stop() async {
    await _stop.call();
    await _peerSub?.cancel();
    _peerSub = null;
    state = const BluetoothMeshState();
  }

  /// Returns best peer location for GPS fallback, or null.
  BluetoothPeer? get bestFallbackPeer => _getDerived.call().fold((_) => null, (p) => p);

  void _subscribeToPeers() {
    final repo = _ref.read(bluetoothLocationRepositoryProvider);
    _peerSub = repo.peersStream.listen((peers) {
      state = state.copyWith(peers: peers);
    });
  }

  Timer? _refreshTimer;

  void _scheduleLocationRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 20), (_) async {
      if (!state.isActive) return;
      try {
        final locationService = _ref.read(locationServiceProvider);
        final position = await locationService.getCurrentLocation();
        final repo = _ref.read(bluetoothLocationRepositoryProvider);
        await repo.updateLocation(
          lat: position.latitude,
          lng: position.longitude,
          accuracy: position.accuracy,
          speedKmh: position.speed * 3.6,
        );
      } catch (_) {
        // GPS unavailable — keep broadcasting last known location.
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _peerSub?.cancel();
    super.dispose();
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final bluetoothMeshProvider =
    StateNotifierProvider<BluetoothMeshNotifier, BluetoothMeshState>((ref) {
  return BluetoothMeshNotifier(
    ref.read(startBluetoothLocationUseCaseProvider),
    ref.read(stopBluetoothLocationUseCaseProvider),
    ref.read(getBluetoothDerivedLocationUseCaseProvider),
    ref,
  );
});

/// Convenience: stream of discovered peers.
final bluetoothPeersProvider = StreamProvider<List<BluetoothPeer>>((ref) {
  final repo = ref.watch(bluetoothLocationRepositoryProvider);
  return repo.peersStream;
});

/// Convenience: best GPS fallback from BT peers.
final bluetoothFallbackPeerProvider = Provider<BluetoothPeer?>((ref) {
  final state = ref.watch(bluetoothMeshProvider);
  if (!state.isActive || state.peers.isEmpty) return null;
  return state.peers.reduce(
    (a, b) => a.estimatedDistanceMeters <= b.estimatedDistanceMeters ? a : b,
  );
});

/// Resolves the device's current location: GPS first, falling back to the
/// closest Bluetooth peer when GPS is unavailable. Re-evaluates whenever
/// the peer list changes so the UI updates as soon as a peer comes into range.
final effectiveLocationProvider = FutureProvider<LocationFix>((ref) async {
  // Re-run whenever the BT mesh discovers/loses peers.
  ref.watch(bluetoothMeshProvider.select((s) => s.peers));

  final useCase = ref.read(getEffectiveLocationUseCaseProvider);
  final result = await useCase.call();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (fix) => fix,
  );
});
