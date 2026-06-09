import 'package:dartz/dartz.dart';
import '../entities/bluetooth_peer.dart';
import '../../core/errors/failures.dart';

abstract class IBluetoothLocationRepository {
  /// Begin advertising our location and scanning for peers simultaneously.
  Future<Either<Failure, void>> startMesh({
    required double lat,
    required double lng,
    required double accuracy,
    required double speedKmh,
  });

  /// Update the broadcast location without full restart.
  Future<void> updateLocation({
    required double lat,
    required double lng,
    required double accuracy,
    required double speedKmh,
  });

  /// Stop all BLE activity.
  Future<void> stopMesh();

  /// Live stream of discovered peers.
  Stream<List<BluetoothPeer>> get peersStream;

  /// Best fallback coordinate when GPS is unavailable.
  /// Returns the closest fresh peer, or null.
  BluetoothPeer? get bestFallbackPeer;

  bool get isActive;
}
