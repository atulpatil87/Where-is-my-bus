import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/stop.dart';

abstract class IStopRepository {
  Future<Either<Failure, List<Stop>>> getNearbyStops({
    required String cityId,
    required double lat,
    required double lng,
    required double radiusMeters,
  });
  Future<Either<Failure, Stop>> getStopWithArrivals(
      String cityId, String stopId);
  Future<Either<Failure, List<Stop>>> getStopsForRoute(
      String cityId, String routeId);
  Future<Either<Failure, List<Stop>>> searchStops(
      String cityId, String query);
  Future<Either<Failure, void>> setArrivalAlert({
    required String stopId,
    required String routeId,
    required int alertBeforeMins,
  });
}
