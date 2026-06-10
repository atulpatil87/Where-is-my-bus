import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../models/pmpml/pmpml_auth_model.dart';
import '../models/pmpml/pmpml_direction_model.dart';
import '../models/pmpml/pmpml_live_bus_model.dart';
import '../models/pmpml/pmpml_route_model.dart';
import '../models/pmpml/pmpml_stop_model.dart';

/// Unified contract for all PMPML / Chartr backend interactions.
abstract class IPmpmlRepository {
  // ── Auth ──────────────────────────────────────────────────────────────────
  bool get isAuthenticated;
  String? get storedMobile;

  /// Whether the stored access token has passed (or is about to pass) its
  /// recorded expiry. False when no expiry was recorded.
  bool get isTokenExpired;

  Future<Either<Failure, bool>> sendOtp(String mobile);
  Future<Either<Failure, PmpmlAuthModel>> verifyOtp(String mobile, String otp);

  /// Silently mints a fresh access token from the stored refresh token (no
  /// OTP). Returns true if a usable session exists afterwards.
  Future<bool> refreshSession();

  Future<void> logout();

  // ── Routes & Stops ────────────────────────────────────────────────────────
  Future<Either<Failure, List<PmpmlRouteModel>>> getRoutes({bool forceRefresh = false});
  Future<Either<Failure, List<PmpmlStopModel>>> getStops({bool forceRefresh = false});
  Future<Either<Failure, List<PmpmlStopModel>>> getNearbyStops(
      double lat, double lng, double radiusMeters);
  Future<Either<Failure, PmpmlStopModel?>> getNearestStop(double lat, double lng);

  // ── Live Buses ────────────────────────────────────────────────────────────
  Future<Either<Failure, List<PmpmlLiveBusModel>>> getLiveBuses(String routeId);

  /// Aggregates live buses across multiple routes (used by the "all live buses
  /// near you" city view that mirrors the official PMPML app).
  Future<Either<Failure, List<PmpmlLiveBusModel>>> getLiveBusesForRoutes(
      List<String> routeIds);

  // ── Directions ────────────────────────────────────────────────────────────
  Future<Either<Failure, PmpmlDirectionModel>> getBusDirections({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  });

  // ── Schedule ──────────────────────────────────────────────────────────────
  Future<Either<Failure, Map<String, dynamic>>> getRouteSchedule(String routeNumber);
  Future<Either<Failure, Map<String, dynamic>>> getScheduleAtStop(
      String routeNumber, String stopId);
}
