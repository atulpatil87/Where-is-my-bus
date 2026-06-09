import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/cell_tower.dart';

/// Crowd-sourced cell-tower → location store, plus the writes that update a
/// bus position from a tower reading (no GPS).
abstract class ITowerRepository {
  /// Looks up the learned fingerprint for a given serving tower.
  Future<Either<Failure, TowerFingerprint>> lookupFingerprint(
    String cityId,
    String cellKey,
  );

  /// Adds one crowd sample for a tower, refining its running-average position.
  /// Optionally GPS-seeded during calibration — never required for tracking.
  Future<Either<Failure, void>> recordFingerprintSample({
    required String cityId,
    required String cellKey,
    required double lat,
    required double lng,
    required String nearestStopId,
    required String nearestStopName,
  });

  /// Publishes a bus position derived purely from a resolved [TowerFix].
  Future<Either<Failure, void>> shareTowerBusLocation({
    required String cityId,
    required String routeId,
    required String routeNumber,
    required TowerFix fix,
  });
}
