import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/stop.dart';
import '../../domain/repositories/i_stop_repository.dart';
import '../datasources/remote/stop_remote_datasource.dart';

class StopRepositoryImpl implements IStopRepository {
  final StopRemoteDataSource _remote;

  StopRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<Stop>>> getNearbyStops({
    required String cityId,
    required double lat,
    required double lng,
    required double radiusMeters,
  }) async {
    try {
      final models = await _remote.getNearbyStops(
        cityId: cityId,
        lat: lat,
        lng: lng,
        radiusMeters: radiusMeters,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Stop>> getStopWithArrivals(
      String cityId, String stopId) async {
    try {
      final model = await _remote.getStopById(cityId, stopId);
      return Right(model.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Stop>>> getStopsForRoute(
      String cityId, String routeId) async {
    try {
      final models = await _remote.getStopsForRoute(cityId, routeId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Stop>>> searchStops(
      String cityId, String query) async {
    // For now, fetch all and filter in memory.
    try {
      final models = await _remote.getNearbyStops(
        cityId: cityId,
        lat: 18.5204,
        lng: 73.8567,
        radiusMeters: 50000,
      );
      final q = query.toLowerCase();
      final filtered = models
          .where((m) => m.name.toLowerCase().contains(q))
          .toList();
      return Right(filtered.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> setArrivalAlert({
    required String stopId,
    required String routeId,
    required int alertBeforeMins,
  }) async {
    // Delegate to NotificationService (handled by provider)
    return const Right(null);
  }
}
