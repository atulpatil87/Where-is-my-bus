import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/services/cell_tower_service.dart';
import '../../entities/cell_tower.dart';
import '../../repositories/i_tower_repository.dart';

/// Turns the device's current serving tower into a map-ready [TowerFix] without
/// ever touching GPS — read the cell, look it up in the crowd map, done.
class ResolveTowerFixUseCase {
  final CellTowerService _towerService;
  final ITowerRepository _towerRepository;

  const ResolveTowerFixUseCase(this._towerService, this._towerRepository);

  Future<Either<Failure, TowerFix>> call({required String cityId}) async {
    if (!await _towerService.hasPermission()) {
      final granted = await _towerService.requestPermission();
      if (!granted) {
        return const Left(LocationPermissionDeniedFailure(
          message: 'Allow location & phone access to read cell towers.',
        ));
      }
    }

    CellTower? cell;
    try {
      cell = await _towerService.getPrimaryCell();
    } on CellTowerException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        return const Left(LocationPermissionDeniedFailure());
      }
      return Left(ServerFailure(message: e.message));
    }

    final servingCell = cell;
    if (servingCell == null) {
      return const Left(
        NotFoundFailure(message: 'No serving cell tower detected.'),
      );
    }

    final lookup =
        await _towerRepository.lookupFingerprint(cityId, servingCell.cellKey);
    return lookup.map((fp) => TowerFix(tower: servingCell, fingerprint: fp));
  }
}
