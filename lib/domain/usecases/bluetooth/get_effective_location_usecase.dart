import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/services/location_service.dart';
import '../../entities/location_fix.dart';
import '../../repositories/i_bluetooth_location_repository.dart';
import '../../repositories/i_city_repository.dart';
import '../bus/resolve_tower_fix_usecase.dart';

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
  final ResolveTowerFixUseCase _resolveTowerFixUseCase;
  final ICityRepository _cityRepository;

  const GetEffectiveLocationUseCase(
    this._locationService,
    this._bluetoothRepository,
    this._resolveTowerFixUseCase,
    this._cityRepository,
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
      if (peer != null) {
        return Right(LocationFix(
          lat: peer.lat,
          lng: peer.lng,
          accuracy: peer.estimatedDistanceMeters,
          source: LocationSource.bluetooth,
          timestamp: peer.timestamp,
        ));
      }

      // Both GPS and Bluetooth failed, attempt Cell Tower fallback
      final cityIdResult = await _cityRepository.getSavedCityId();
      return cityIdResult.fold(
        (failure) => const Left(LocationTimeoutFailure(
          message:
              'GPS is off, no Bluetooth peers found, and no city selected for cell tower fallback.',
        )),
        (cityId) async {
          final towerFixResult =
              await _resolveTowerFixUseCase.call(cityId: cityId);
          return towerFixResult.fold(
            (failure) => const Left(LocationTimeoutFailure(
              message:
                  'GPS is off, no nearby Bluetooth peers were found, and cell tower tracking failed. '
                  'Enable Location services.',
            )),
            (towerFix) => Right(LocationFix(
              lat: towerFix.lat,
              lng: towerFix.lng,
              accuracy: 1000.0, // Cell tower accuracy is typically low
              source: LocationSource.cellTower,
              timestamp: DateTime.now(),
            )),
          );
        },
      );
    }
  }
}
