import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class IUserRepository {
  // Auth
  Future<Either<Failure, User>> signInWithGoogle();
  Future<Either<Failure, String>> sendOTP(String phone);
  Future<Either<Failure, User>> verifyOTP(String otp, String phone);
  Future<Either<Failure, User>> signInAsGuest();
  Future<Either<Failure, void>> signOut();
  Stream<User?> get authStateChanges;

  // Profile
  Future<Either<Failure, User>> getUserProfile(String userId);
  Future<Either<Failure, void>> updateProfile(User user);

  // Saved items
  Future<Either<Failure, void>> saveRoute(String routeId);
  Future<Either<Failure, void>> unsaveRoute(String routeId);
  Future<Either<Failure, void>> saveStop(String stopId);
  Future<Either<Failure, void>> unsaveStop(String stopId);

  // Trips
  Future<Either<Failure, void>> startTrip(Trip trip);
  Future<Either<Failure, void>> endTrip(String tripId);
  Future<Either<Failure, List<Trip>>> getTripHistory(String userId);

  // Stats
  Future<Either<Failure, UserStats>> getUserStats(String userId);
}
