import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../datasources/remote/pmpml/pmpml_auth_datasource.dart';
import '../datasources/remote/pmpml/pmpml_directions_datasource.dart';
import '../datasources/remote/pmpml/pmpml_live_datasource.dart';
import '../datasources/remote/pmpml/pmpml_routes_datasource.dart';
import '../datasources/remote/pmpml/pmpml_schedule_datasource.dart';
import '../models/pmpml/pmpml_auth_model.dart';
import '../models/pmpml/pmpml_direction_model.dart';
import '../models/pmpml/pmpml_live_bus_model.dart';
import '../models/pmpml/pmpml_route_model.dart';
import '../models/pmpml/pmpml_stop_model.dart';
import 'i_pmpml_repository.dart';

class PmpmlRepositoryImpl implements IPmpmlRepository {
  final PmpmlAuthDataSource _auth;
  final PmpmlRoutesDataSource _routes;
  final PmpmlLiveDataSource _live;
  final PmpmlDirectionsDataSource _directions;
  final PmpmlScheduleDataSource _schedule;

  PmpmlRepositoryImpl({
    required PmpmlAuthDataSource auth,
    required PmpmlRoutesDataSource routes,
    required PmpmlLiveDataSource live,
    required PmpmlDirectionsDataSource directions,
    required PmpmlScheduleDataSource schedule,
  })  : _auth = auth,
        _routes = routes,
        _live = live,
        _directions = directions,
        _schedule = schedule;

  // ── Auth ──────────────────────────────────────────────────────────────────

  @override
  bool get isAuthenticated => _auth.isAuthenticated;

  @override
  String? get storedMobile => _auth.getStoredMobile();

  @override
  bool get isTokenExpired => _auth.isTokenExpired();

  @override
  Future<bool> refreshSession() async {
    final auth = await _auth.refreshAccessToken();
    return auth != null;
  }

  @override
  Future<Either<Failure, bool>> sendOtp(String mobile) async {
    try {
      final result = await _auth.sendOtp(mobile);
      return Right(result);
    } on AppException catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, PmpmlAuthModel>> verifyOtp(
      String mobile, String otp) async {
    try {
      final result = await _auth.verifyOtp(mobile, otp);
      return Right(result);
    } on AppException catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<void> logout() => _auth.clearTokens();

  // ── Routes & Stops ────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<PmpmlRouteModel>>> getRoutes(
      {bool forceRefresh = false}) async {
    try {
      final data = await _routes.getCombinedData(forceRefresh: forceRefresh);
      return Right(data.routes);
    } on AppException catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, List<PmpmlStopModel>>> getStops(
      {bool forceRefresh = false}) async {
    try {
      final data = await _routes.getCombinedData(forceRefresh: forceRefresh);
      return Right(data.stops);
    } on AppException catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, List<PmpmlStopModel>>> getNearbyStops(
      double lat, double lng, double radiusMeters) async {
    try {
      final stops = await _routes.getNearbyStops(lat, lng, radiusMeters);
      return Right(stops);
    } on AppException catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, PmpmlStopModel?>> getNearestStop(
      double lat, double lng) async {
    try {
      final stop = await _routes.getNearestStop(lat, lng);
      return Right(stop);
    } on AppException catch (e) {
      return Left(_mapException(e));
    }
  }

  // ── Live Buses ────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<PmpmlLiveBusModel>>> getLiveBuses(
      String routeId) async {
    try {
      final buses = await _live.getBusesOnRoute(routeId);
      return Right(buses);
    } on AppException catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, List<PmpmlLiveBusModel>>> getLiveBusesForRoutes(
      List<String> routeIds) async {
    try {
      final buses = await _live.getBusesOnRoutes(routeIds);
      return Right(buses);
    } on AppException catch (e) {
      return Left(_mapException(e));
    }
  }

  // ── Directions ────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, PmpmlDirectionModel>> getBusDirections({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) async {
    try {
      final result = await _directions.getBusDirections(
        fromLat: fromLat,
        fromLng: fromLng,
        toLat: toLat,
        toLng: toLng,
      );
      return Right(result);
    } on AppException catch (e) {
      return Left(_mapException(e));
    }
  }

  // ── Schedule ──────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Map<String, dynamic>>> getRouteSchedule(
      String routeNumber) async {
    try {
      final result = await _schedule.getRouteSchedule(routeNumber);
      return Right(result);
    } on AppException catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getScheduleAtStop(
      String routeNumber, String stopId) async {
    try {
      final result = await _schedule.getScheduleAtStop(routeNumber, stopId);
      return Right(result);
    } on AppException catch (e) {
      return Left(_mapException(e));
    }
  }

  // ── Exception → Failure mapping ───────────────────────────────────────────

  Failure _mapException(AppException e) {
    if (e is NetworkException) return const NetworkFailure();
    if (e is TimeoutException) return const TimeoutFailure();
    if (e is UnauthorizedException) return const UnauthorizedFailure();
    if (e is NotFoundException) return NotFoundFailure(message: e.message);
    if (e is InvalidInputException) return InvalidInputFailure(message: e.message);
    return ServerFailure(message: e.message, code: e.statusCode);
  }
}
