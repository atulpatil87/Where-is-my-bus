import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/cell_tower.dart';
import '../../domain/repositories/i_tower_repository.dart';
import '../datasources/remote/tower_remote_datasource.dart';

class TowerRepositoryImpl implements ITowerRepository {
  final TowerRemoteDataSource _remote;

  TowerRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, TowerFingerprint>> lookupFingerprint(
    String cityId,
    String cellKey,
  ) async {
    try {
      final model = await _remote.getFingerprint(cityId, cellKey);
      if (model == null) {
        return const Left(
          NotFoundFailure(message: 'This tower has not been mapped yet.'),
        );
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> recordFingerprintSample({
    required String cityId,
    required String cellKey,
    required double lat,
    required double lng,
    required String nearestStopId,
    required String nearestStopName,
  }) async {
    try {
      await _remote.upsertFingerprintSample(
        cityId: cityId,
        cellKey: cellKey,
        lat: lat,
        lng: lng,
        nearestStopId: nearestStopId,
        nearestStopName: nearestStopName,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> shareTowerBusLocation({
    required String cityId,
    required String routeId,
    required String routeNumber,
    required TowerFix fix,
  }) async {
    try {
      await _remote.writeTowerBusLocation(
        cityId: cityId,
        routeId: routeId,
        routeNumber: routeNumber,
        lat: fix.lat,
        lng: fix.lng,
        nextStopId: fix.nearestStopId,
        nextStopName: fix.nearestStopName,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
