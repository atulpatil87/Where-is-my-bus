import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/services/bluetooth_location_service.dart';
import '../../domain/entities/bluetooth_peer.dart';
import '../../domain/repositories/i_bluetooth_location_repository.dart';

class BluetoothLocationRepositoryImpl
    implements IBluetoothLocationRepository {
  final BluetoothLocationService _service;

  BluetoothLocationRepositoryImpl(this._service);

  bool _active = false;

  @override
  Future<Either<Failure, void>> startMesh({
    required double lat,
    required double lng,
    required double accuracy,
    required double speedKmh,
  }) async {
    try {
      final advertisingOk = await _service.startAdvertising(
        lat: lat,
        lng: lng,
        accuracy: accuracy,
        speedKmh: speedKmh,
      );
      final scanningOk = await _service.startScanning();

      if (!advertisingOk && !scanningOk) {
        return const Left(
          BluetoothFailure(message: 'Bluetooth is off or permission denied.'),
        );
      }

      _active = true;
      return const Right(null);
    } catch (e) {
      return Left(BluetoothFailure(message: e.toString()));
    }
  }

  @override
  Future<void> updateLocation({
    required double lat,
    required double lng,
    required double accuracy,
    required double speedKmh,
  }) =>
      _service.updateAdvertisedLocation(
        lat: lat,
        lng: lng,
        accuracy: accuracy,
        speedKmh: speedKmh,
      );

  @override
  Future<void> stopMesh() async {
    await _service.stopAdvertising();
    await _service.stopScanning();
    _active = false;
  }

  @override
  Stream<List<BluetoothPeer>> get peersStream => _service.peersStream;

  @override
  BluetoothPeer? get bestFallbackPeer => _service.bestFallbackPeer;

  @override
  bool get isActive => _active;
}
