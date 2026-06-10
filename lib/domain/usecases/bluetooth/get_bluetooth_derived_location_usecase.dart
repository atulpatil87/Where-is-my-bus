import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/bluetooth_peer.dart';
import '../../repositories/i_bluetooth_location_repository.dart';

/// Returns the best location estimate derived from nearby BLE peers.
/// Intended as a GPS fallback — caller should show a disclaimer to the user.
class GetBluetoothDerivedLocationUseCase {
  final IBluetoothLocationRepository _repo;

  const GetBluetoothDerivedLocationUseCase(this._repo);

  Either<Failure, BluetoothPeer> call() {
    final peer = _repo.bestFallbackPeer;
    if (peer == null) {
      return const Left(NoPeersFailure());
    }
    return Right(peer);
  }
}
