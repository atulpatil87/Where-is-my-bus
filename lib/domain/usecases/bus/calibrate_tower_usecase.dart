import 'package:dartz/dartz.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failures.dart';
import '../../../core/services/cell_tower_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/utils/distance_utils.dart';
import '../../repositories/i_stop_repository.dart';
import '../../repositories/i_tower_repository.dart';

/// Seeds the crowd tower→location map. This is the ONE place a GPS fix is used,
/// and only opt-in: when a willing rider has a good fix we attach it to the
/// tower they're camped on, so everyone else can later be located GPS-free.
/// Mirrors how WiMT bootstraps its tower database from early contributors.
class CalibrateTowerUseCase {
  final CellTowerService _towerService;
  final LocationService _locationService;
  final IStopRepository _stopRepository;
  final ITowerRepository _towerRepository;

  const CalibrateTowerUseCase(
    this._towerService,
    this._locationService,
    this._stopRepository,
    this._towerRepository,
  );

  Future<Either<Failure, void>> call({required String cityId}) async {
    final cell = await _towerService.getPrimaryCell();
    if (cell == null) {
      return const Left(NotFoundFailure(message: 'No serving cell detected.'));
    }

    final position = await _locationService.getCurrentLocation();
    if (position.accuracy > AppConstants.towerCalibrationMaxAccuracyMeters) {
      return const Left(LocationTimeoutFailure(
        message: 'GPS fix too coarse to calibrate this tower.',
      ));
    }

    // Attach the nearest known stop so consumers get a human-readable position.
    final nearby = await _stopRepository.getNearbyStops(
      cityId: cityId,
      lat: position.latitude,
      lng: position.longitude,
      radiusMeters: AppConstants.maxNearbyRadiusMeters,
    );

    String stopId = '';
    String stopName = 'Near tower';
    nearby.fold((_) {}, (stops) {
      if (stops.isEmpty) return;
      stops.sort((a, b) {
        final da = DistanceUtils.haversineMeters(
            position.latitude, position.longitude, a.lat, a.lng);
        final db = DistanceUtils.haversineMeters(
            position.latitude, position.longitude, b.lat, b.lng);
        return da.compareTo(db);
      });
      stopId = stops.first.id;
      stopName = stops.first.name;
    });

    return _towerRepository.recordFingerprintSample(
      cityId: cityId,
      cellKey: cell.cellKey,
      lat: position.latitude,
      lng: position.longitude,
      nearestStopId: stopId,
      nearestStopName: stopName,
    );
  }
}
