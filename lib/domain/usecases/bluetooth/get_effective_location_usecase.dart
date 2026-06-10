import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/services/location_service.dart';
import '../../entities/location_fix.dart';
import '../../repositories/i_bluetooth_location_repository.dart';

/// Resolves the device's current location, preferring GPS but falling
/// back to the closest Bluetooth peer's broadcast location when GPS is
/// off, has no fix, or times out.
///
/// This is what lets the app keep working — nearby stops, live map
/// position, etc. — even when the user has disabled location services,
/// as long as another BusIndia user is within Bluetooth range.
class GetEffectiveLocationUseCase {
  final LocationService _locationService;
  final IBluetoothLocationRepository _bluetoothRepository;

  const GetEffectiveLocationUseCase(
    this._locationService,
    this._bluetoothRepository,
  );

  Future<Either<Failure, LocationFix>> call() async {
    try {
      final position = await _locationService.getCurrentLocation();
      return Right(LocationFix(
        lat: position.latitude,
        lng: position.longitude,
        accuracy: position.accuracy,
        source: LocationSource.gps,
        timestamp: DateTime.now(),
      ));
    } catch (_) {
      final peer = _bluetoothRepository.bestFallbackPeer;
      if (peer == null) {
        return const Left(
          LocationTimeoutFailure(
            message:
                'GPS is off and no nearby Bluetooth peers were found. '
                'Enable Bluetooth location sharing to use a nearby device as fallback.',
          ),
        );
      }
      return Right(LocationFix(
        lat: peer.lat,
        lng: peer.lng,
        accuracy: peer.estimatedDistanceMeters,
        source: LocationSource.bluetooth,
        timestamp: peer.timestamp,
      ));
    }
  }
}
