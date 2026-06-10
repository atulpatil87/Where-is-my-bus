import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/services/location_service.dart';
import '../../repositories/i_bluetooth_location_repository.dart';

/// Starts the BLE mesh: advertise own location + scan for peers.
/// Fetches the current GPS position first; falls back to provided
/// [fallbackLat]/[fallbackLng] when GPS is unavailable.
class StartBluetoothLocationUseCase {
  final IBluetoothLocationRepository _repo;
  final LocationService _locationService;

  const StartBluetoothLocationUseCase(this._repo, this._locationService);

  Future<Either<Failure, void>> call({
    double? fallbackLat,
    double? fallbackLng,
  }) async {
    double lat;
    double lng;
    double accuracy;
    double speedKmh;

    try {
      final position = await _locationService.getCurrentLocation();
      lat = position.latitude;
      lng = position.longitude;
      accuracy = position.accuracy;
      speedKmh = position.speed * 3.6;
    } catch (_) {
      // GPS unavailable — use provided fallback coordinates.
      if (fallbackLat == null || fallbackLng == null) {
        return const Left(
          LocationTimeoutFailure(
            message: 'GPS unavailable. Provide a known location to start Bluetooth sharing.',
          ),
        );
      }
      lat = fallbackLat;
      lng = fallbackLng;
      accuracy = 999.0; // Signal that accuracy is unknown.
      speedKmh = 0.0;
    }

    return _repo.startMesh(
      lat: lat,
      lng: lng,
      accuracy: accuracy,
      speedKmh: speedKmh,
    );
  }
}
