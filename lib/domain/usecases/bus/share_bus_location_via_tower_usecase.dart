import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/cell_tower.dart';
import '../../repositories/i_tower_repository.dart';
import '../../repositories/i_user_repository.dart';
import 'resolve_tower_fix_usecase.dart';

/// Publishes the rider's bus position using only the serving cell tower — the
/// GPS-free equivalent of [ShareBusLocationUseCase]. One read per tick, mapped
/// through the crowd fingerprint store, written to the live feed.
class ShareBusLocationViaTowerUseCase {
  final ResolveTowerFixUseCase _resolveFix;
  final ITowerRepository _towerRepository;
  final IUserRepository _userRepository;

  const ShareBusLocationViaTowerUseCase(
    this._resolveFix,
    this._towerRepository,
    this._userRepository,
  );

  Future<Either<Failure, TowerFix>> call({
    required String cityId,
    required String routeId,
    required String routeNumber,
  }) async {
    final user = await _userRepository.authStateChanges.first;
    if (user == null || user.isGuest) {
      return const Left(AuthFailure(message: 'Sign in to share location.'));
    }
    if (!user.preferences.shareLocation) {
      return const Left(
        AuthFailure(message: 'Enable location sharing in preferences.'),
      );
    }

    final fixResult = await _resolveFix.call(cityId: cityId);
    if (fixResult.isLeft()) {
      // Same Either<Failure, TowerFix> type — forward the failure as-is.
      return fixResult;
    }

    final fix = fixResult.getOrElse(
      () => throw StateError('Right value expected after isLeft() check'),
    );
    final write = await _towerRepository.shareTowerBusLocation(
      cityId: cityId,
      routeId: routeId,
      routeNumber: routeNumber,
      fix: fix,
    );
    return write.map((_) => fix);
  }
}
