import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as fbauth;
import '../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/i_user_repository.dart';
import '../datasources/remote/user_remote_datasource.dart';

class UserRepositoryImpl implements IUserRepository {
  final UserRemoteDataSource _remote;

  UserRepositoryImpl(this._remote, fbauth.FirebaseAuth _);

  @override
  Stream<User?> get authStateChanges => _remote.authStateChanges.asyncMap(
        (fbUser) async {
          if (fbUser == null) return null;
          try {
            final model = await _remote.getUserProfile(fbUser.uid);
            return model.toEntity();
          } catch (_) {
            // Return minimal guest user if profile not yet created
            return User(
              id: fbUser.uid,
              name: fbUser.displayName ?? 'User',
              email: fbUser.email,
              authProvider: 'google',
              selectedCities: const ['pune'],
              primaryCity: 'pune',
              savedRoutes: const [],
              savedStops: const [],
              preferences: const UserPreferences(),
              stats: const UserStats(),
              badges: const [],
              createdAt: DateTime.now(),
              lastActiveAt: DateTime.now(),
            );
          }
        },
      );

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      final model = await _remote.signInWithGoogle();
      return Right(model.toEntity());
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> sendOTP(String phone) async {
    try {
      final verificationId = await _remote.sendOTP(phone);
      return Right(verificationId);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> verifyOTP(
      String otp, String phone) async {
    try {
      final model = await _remote.verifyOTP(otp, phone);
      return Right(model.toEntity());
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signInAsGuest() async {
    final guestUser = User(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Guest',
      authProvider: 'guest',
      selectedCities: const ['pune'],
      primaryCity: 'pune',
      savedRoutes: const [],
      savedStops: const [],
      preferences: const UserPreferences(),
      stats: const UserStats(),
      badges: const [],
      createdAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
    );
    return Right(guestUser);
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remote.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getUserProfile(String userId) async {
    try {
      final model = await _remote.getUserProfile(userId);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile(User user) async {
    // Convert entity back to model for persistence — simplified
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> saveRoute(String routeId) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> unsaveRoute(String routeId) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> saveStop(String stopId) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> unsaveStop(String stopId) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> startTrip(Trip trip) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> endTrip(String tripId) async =>
      const Right(null);

  @override
  Future<Either<Failure, List<Trip>>> getTripHistory(String userId) async =>
      const Right([]);

  @override
  Future<Either<Failure, UserStats>> getUserStats(String userId) async {
    try {
      final model = await _remote.getUserProfile(userId);
      return Right(model.stats.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
