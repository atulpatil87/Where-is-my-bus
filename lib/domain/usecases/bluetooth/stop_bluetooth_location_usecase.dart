import '../../repositories/i_bluetooth_location_repository.dart';

/// Stops all BLE mesh activity (advertising + scanning).
class StopBluetoothLocationUseCase {
  final IBluetoothLocationRepository _repo;

  const StopBluetoothLocationUseCase(this._repo);

  Future<void> call() => _repo.stopMesh();
}
