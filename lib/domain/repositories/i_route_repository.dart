import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/route.dart';
import '../entities/timetable.dart';

abstract class IRouteRepository {
  Future<Either<Failure, List<RouteResult>>> findRoutes({
    required String cityId,
    required String fromStopId,
    required String toStopId,
    DateTime? travelTime,
  });
  Future<Either<Failure, Timetable>> getRouteTimetable(
      String cityId, String routeId);
  Future<Either<Failure, Route>> getRouteDetail(
      String cityId, String routeId);
  Future<Either<Failure, List<Route>>> searchRoutes(
      String cityId, String query);
  Future<Either<Failure, List<Route>>> getAllRoutes(String cityId);
  Future<Either<Failure, void>> downloadTimetableOffline(
      String cityId, String routeId);
  Future<Either<Failure, Timetable?>> getOfflineTimetable(
      String cityId, String routeId);
}
