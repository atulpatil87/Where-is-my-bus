import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/network/network_info.dart';
import '../../entities/bus.dart';
import '../../repositories/i_bus_repository.dart';

class BusFilter {
  final String? busType;
  final bool onTimeOnly;
  final bool crowdedOnly;

  const BusFilter({
    this.busType,
    this.onTimeOnly = false,
    this.crowdedOnly = false,
  });

  static const empty = BusFilter();
}

/// Powers Live Map Screen. Returns a Stream from Realtime DB.
class GetLiveBusesUseCase {
  final IBusRepository _busRepository;
  final INetworkInfo _networkInfo;

  const GetLiveBusesUseCase(this._busRepository, this._networkInfo);

  Stream<Either<Failure, List<Bus>>> call({
    required String cityId,
    String? filterRouteId,
    BusFilter filter = BusFilter.empty,
  }) async* {
    final connected = await _networkInfo.isConnected;
    if (!connected) {
      yield const Left(OfflineFailure());
      return;
    }

    final stream = filterRouteId != null
        ? _busRepository.getLiveBusesByRoute(cityId, filterRouteId)
        : _busRepository.getLiveBuses(cityId);

    await for (final result in stream) {
      yield result.map((buses) => _applyFilter(buses, filter));
    }
  }

  List<Bus> _applyFilter(List<Bus> buses, BusFilter filter) {
    return buses.where((bus) {
      if (filter.onTimeOnly && bus.status != BusStatus.onTime) return false;
      if (filter.crowdedOnly && bus.crowdLevel < 3) return false;
      return true;
    }).toList();
  }
}
