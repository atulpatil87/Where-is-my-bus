import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/timetable.dart';
import '../../repositories/i_route_repository.dart';

class GetRouteTimetableUseCase {
  final IRouteRepository _repository;
  const GetRouteTimetableUseCase(this._repository);

  Future<Either<Failure, Timetable>> call(
      String cityId, String routeId) async {
    // Try offline first
    final offline = await _repository.getOfflineTimetable(cityId, routeId);
    final offlineTt = offline.getOrElse(() => null);
    if (offlineTt != null) return Right(offlineTt);

    // Otherwise fetch from Firestore
    return _repository.getRouteTimetable(cityId, routeId);
  }
}
