import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/route.dart';
import '../../domain/entities/timetable.dart';
import '../../domain/repositories/i_route_repository.dart';
import '../datasources/remote/route_remote_datasource.dart';
import '../datasources/local/local_datasources.dart';
import '../models/route_model.dart';

class RouteRepositoryImpl implements IRouteRepository {
  final RouteRemoteDataSource _remote;
  final TimetableLocalDataSource _local;

  // Simple in-memory route cache per city
  final Map<String, List<RouteModel>> _routeCache = {};

  RouteRepositoryImpl(this._remote, this._local);

  @override
  Future<Either<Failure, List<Route>>> getAllRoutes(String cityId) async {
    try {
      if (_routeCache.containsKey(cityId)) {
        return Right(
          _routeCache[cityId]!.map((m) => m.toEntity()).toList(),
        );
      }
      final models = await _remote.getAllRoutes(cityId);
      _routeCache[cityId] = models;
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Route>> getRouteDetail(
      String cityId, String routeId) async {
    try {
      final model = await _remote.getRouteById(cityId, routeId);
      return Right(model.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Route>>> searchRoutes(
      String cityId, String query) async {
    final allResult = await getAllRoutes(cityId);
    return allResult.map((routes) {
      final q = query.toLowerCase();
      return routes
          .where((r) =>
              r.routeNumber.toLowerCase().contains(q) ||
              r.routeName.toLowerCase().contains(q))
          .toList();
    });
  }

  @override
  Future<Either<Failure, List<RouteResult>>> findRoutes({
    required String cityId,
    required String fromStopId,
    required String toStopId,
    DateTime? travelTime,
  }) async {
    // Load all routes with stop adjacency for BFS graph search
    final allResult = await getAllRoutes(cityId);
    return allResult.map((routes) {
      final results = <RouteResult>[];

      // 1. Direct routes: routes that contain BOTH stops
      final directRoutes = routes.where((r) =>
          r.stopIds.contains(fromStopId) &&
          r.stopIds.contains(toStopId)).toList();

      for (final r in directRoutes) {
        final fromIdx = r.stopIds.indexOf(fromStopId);
        final toIdx = r.stopIds.indexOf(toStopId);
        if (fromIdx < toIdx) {
          // Valid direction
          final stopCount = toIdx - fromIdx;
          results.add(RouteResult(
            type: 'direct',
            segments: [
              RouteSegment(
                routeId: r.id,
                routeNumber: r.routeNumber,
                routeName: r.routeName,
                busType: r.busType,
                fromStopId: fromStopId,
                fromStopName: fromStopId,
                toStopId: toStopId,
                toStopName: toStopId,
                stopCount: stopCount,
                durationMins:
                    (r.durationMins * stopCount / r.totalStops).round(),
                fare: (r.fareMin +
                        ((r.fareMax - r.fareMin) * stopCount / r.totalStops))
                    .round(),
                crowdLevel: 2,
              )
            ],
            totalDurationMins:
                (r.durationMins * stopCount / r.totalStops).round(),
            totalFare: (r.fareMin +
                    ((r.fareMax - r.fareMin) * stopCount / r.totalStops))
                .round(),
            walkDistanceMeters: 200,
            totalStops: stopCount,
            crowdLevel: 2,
            isFastest: false,
            isLeastCrowded: false,
            isCheapest: false,
          ));
        }
      }

      // 2. One-interchange routes: BFS with max 2 route segments
      if (results.isEmpty) {
        final fromRoutes =
            routes.where((r) => r.stopIds.contains(fromStopId)).toList();
        final toRoutes =
            routes.where((r) => r.stopIds.contains(toStopId)).toList();

        for (final r1 in fromRoutes) {
          for (final r2 in toRoutes) {
            if (r1.id == r2.id) continue;
            // Find common interchange stop
            final common = r1.stopIds
                .toSet()
                .intersection(r2.stopIds.toSet())
                .where((s) => s != fromStopId && s != toStopId)
                .toList();
            if (common.isNotEmpty) {
              final interchange = common.first;
              results.add(RouteResult(
                type: 'one_change',
                segments: [
                  RouteSegment(
                    routeId: r1.id,
                    routeNumber: r1.routeNumber,
                    routeName: r1.routeName,
                    busType: r1.busType,
                    fromStopId: fromStopId,
                    fromStopName: fromStopId,
                    toStopId: interchange,
                    toStopName: interchange,
                    stopCount: 5,
                    durationMins: 20,
                    fare: r1.fareMin,
                    crowdLevel: 2,
                  ),
                  RouteSegment(
                    routeId: r2.id,
                    routeNumber: r2.routeNumber,
                    routeName: r2.routeName,
                    busType: r2.busType,
                    fromStopId: interchange,
                    fromStopName: interchange,
                    toStopId: toStopId,
                    toStopName: toStopId,
                    stopCount: 8,
                    durationMins: 25,
                    fare: r2.fareMin,
                    crowdLevel: 3,
                  ),
                ],
                totalDurationMins: 45 + 5, // +5 wait time
                totalFare: r1.fareMin + r2.fareMin,
                walkDistanceMeters: 100,
                totalStops: 13,
                crowdLevel: 3,
                isFastest: false,
                isLeastCrowded: false,
                isCheapest: false,
              ));
              break; // one interchange result per pair
            }
          }
          if (results.length >= 3) break;
        }
      }

      return results.take(5).toList();
    });
  }

  @override
  Future<Either<Failure, Timetable>> getRouteTimetable(
      String cityId, String routeId) async {
    try {
      final model = await _remote.getRouteTimetable(cityId, routeId);
      return Right(model.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> downloadTimetableOffline(
      String cityId, String routeId) async {
    try {
      final model = await _remote.getRouteTimetable(cityId, routeId);
      await _local.saveTimetable(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Timetable?>> getOfflineTimetable(
      String cityId, String routeId) async {
    try {
      final model = await _local.getTimetable(cityId, routeId);
      return Right(model?.toEntity());
    } catch (e) {
      return Right(null);
    }
  }
}
