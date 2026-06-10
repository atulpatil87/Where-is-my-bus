import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/distance_utils.dart';
import '../../../core/services/location_service.dart';
import '../../entities/stop.dart';
import '../../repositories/i_stop_repository.dart';

/// Powers Nearby Stops Screen (Tab 3).
class GetNearbyStopsUseCase {
  final IStopRepository _stopRepository;
  final LocationService _locationService;

  const GetNearbyStopsUseCase(this._stopRepository, this._locationService);

  Future<Either<Failure, List<Stop>>> call({
    required String cityId,
    double radiusMeters = 500,
    double? lat,
    double? lng,
  }) async {
    try {
      double resolvedLat;
      double resolvedLng;
      if (lat != null && lng != null) {
        resolvedLat = lat;
        resolvedLng = lng;
      } else {
        final position = await _locationService.getCurrentLocation();
        resolvedLat = position.latitude;
        resolvedLng = position.longitude;
      }

      final result = await _stopRepository.getNearbyStops(
        cityId: cityId,
        lat: resolvedLat,
        lng: resolvedLng,
        radiusMeters: radiusMeters,
      );

      return result.map((stops) {
        final enriched = stops.map((stop) {
          final dist = DistanceUtils.haversineMeters(resolvedLat, resolvedLng, stop.lat, stop.lng);
          final walk = _locationService.getWalkingMins(dist);
          return stop.copyWith(distanceMeters: dist, walkingMins: walk);
        }).toList();
        enriched.sort(
          (a, b) => (a.distanceMeters ?? 0).compareTo(b.distanceMeters ?? 0),
        );
        return enriched;
      });
    } on Exception catch (e) {
      return Left(LocationPermissionDeniedFailure(message: e.toString()));
    }
  }
}
