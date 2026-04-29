import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../core/constants/firebase_constants.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/bus.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/i_bus_repository.dart';
import '../datasources/remote/bus_remote_datasource.dart';

class BusRepositoryImpl implements IBusRepository {
  final BusRemoteDataSource _remote;
  final FirebaseFirestore _firestore;

  BusRepositoryImpl(this._remote, this._firestore);

  @override
  Stream<Either<Failure, List<Bus>>> getLiveBuses(String cityId) {
    return _remote.getLiveBuses(cityId).map<Either<Failure, List<Bus>>>(
          (models) => Right(models.map((m) => m.toEntity()).toList()),
        );
  }

  @override
  Stream<Either<Failure, List<Bus>>> getLiveBusesByRoute(
      String cityId, String routeId) {
    return _remote
        .getLiveBusesByRoute(cityId, routeId)
        .map<Either<Failure, List<Bus>>>(
          (models) => Right(models.map((m) => m.toEntity()).toList()),
        );
  }

  @override
  Future<Either<Failure, Bus>> getBusDetail(
      String cityId, String busId) async {
    // Realtime DB single bus fetch — live data only
    return const Left(NotFoundFailure(message: 'Bus not found.'));
  }

  @override
  Future<Either<Failure, void>> shareBusLocation({
    required String routeId,
    required double lat,
    required double lng,
    required double heading,
    required double speedKmh,
  }) async {
    try {
      // cityId resolved from location in use case
      await _remote.writeCommunityBusLocation(
        cityId: 'pune', // resolved in the use case
        routeId: routeId,
        lat: lat,
        lng: lng,
        heading: heading,
        speedKmh: speedKmh,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> submitCrowdReport(
      CrowdReport report) async {
    try {
      await _firestore
          .collection(FirebaseConstants.collectionCrowdReports)
          .add({
        'busId': report.busId,
        'routeId': report.routeId,
        'cityId': report.cityId,
        'userId': report.userId,
        'crowdLevel': report.crowdLevel,
        'crowdLabel': report.crowdLabel,
        'location': {'lat': report.lat, 'lng': report.lng},
        'reportedAt': Timestamp.fromDate(report.reportedAt),
        'expiresAt': Timestamp.fromDate(report.expiresAt),
        'isVerified': false,
      });
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Firestore error'));
    }
  }

  @override
  Future<Either<Failure, void>> confirmBusArrival({
    required String busId,
    required String stopId,
    required String routeId,
  }) async {
    // Can be extended to write confirmation to Firestore
    return const Right(null);
  }
}
