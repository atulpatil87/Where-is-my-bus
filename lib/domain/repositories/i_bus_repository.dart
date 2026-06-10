import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/bus.dart';
import '../entities/user.dart';

abstract class IBusRepository {
  Stream<Either<Failure, List<Bus>>> getLiveBuses(String cityId);
  Stream<Either<Failure, List<Bus>>> getLiveBusesByRoute(
      String cityId, String routeId);
  Future<Either<Failure, Bus>> getBusDetail(String cityId, String busId);
  Future<Either<Failure, void>> shareBusLocation({
    required String routeId,
    required double lat,
    required double lng,
    required double heading,
    required double speedKmh,
  });
  Future<Either<Failure, void>> submitCrowdReport(CrowdReport report);
  Future<Either<Failure, void>> confirmBusArrival({
    required String busId,
    required String stopId,
    required String routeId,
  });
}
