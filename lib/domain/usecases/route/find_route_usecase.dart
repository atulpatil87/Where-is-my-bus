import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/route.dart';
import '../../repositories/i_route_repository.dart';

/// Powers Route Finder Screen (Tab 2).
class FindRouteUseCase {
  final IRouteRepository _routeRepository;

  const FindRouteUseCase(this._routeRepository);

  Future<Either<Failure, List<RouteResult>>> call({
    required String cityId,
    required String fromStopId,
    required String toStopId,
    DateTime? travelTime,
  }) async {
    if (fromStopId == toStopId) {
      return const Left(
        InvalidInputFailure(message: 'Origin and destination cannot be the same.'),
      );
    }

    final result = await _routeRepository.findRoutes(
      cityId: cityId,
      fromStopId: fromStopId,
      toStopId: toStopId,
      travelTime: travelTime,
    );

    return result.map((results) {
      if (results.isEmpty) return results;

      final fastest = results.reduce(
        (a, b) => a.totalDurationMins < b.totalDurationMins ? a : b,
      );
      final cheapest = results.reduce(
        (a, b) => a.totalFare < b.totalFare ? a : b,
      );
      final leastCrowded = results.reduce(
        (a, b) => a.crowdLevel < b.crowdLevel ? a : b,
      );

      return results.map((r) => RouteResult(
            type: r.type,
            segments: r.segments,
            totalDurationMins: r.totalDurationMins,
            totalFare: r.totalFare,
            walkDistanceMeters: r.walkDistanceMeters,
            totalStops: r.totalStops,
            crowdLevel: r.crowdLevel,
            isFastest: r == fastest,
            isCheapest: r == cheapest,
            isLeastCrowded: r == leastCrowded,
          )).toList();
    });
  }
}
