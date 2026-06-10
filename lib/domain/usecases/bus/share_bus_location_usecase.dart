import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/location_service.dart';
import '../../repositories/i_bus_repository.dart';
import '../../repositories/i_user_repository.dart';

/// Community feature — user shares GPS while on bus.
class ShareBusLocationUseCase {
  final IBusRepository _busRepository;
  final IUserRepository _userRepository;
  final LocationService _locationService;

  const ShareBusLocationUseCase(
    this._busRepository,
    this._userRepository,
    this._locationService,
  );

  Future<Either<Failure, void>> call({
    required String routeId,
    required double lat,
    required double lng,
    required double heading,
    required double speedKmh,
  }) async {
    final user = await _userRepository.authStateChanges.first;
    if (user == null) {
      return const Left(AuthFailure(message: 'Sign in to share location.'));
    }
    if (user.isGuest) {
      return const Left(AuthFailure(message: 'Sign in to share your location.'));
    }
    if (!user.preferences.shareLocation) {
      return const Left(
        AuthFailure(message: 'Enable location sharing in preferences.'),
      );
    }
    if (speedKmh < AppConstants.minBusSpeedKmh) {
      return const Left(
        InvalidInputFailure(message: 'Speed too low — are you on a bus?'),
      );
    }
    final cityId = _locationService.detectCity(lat, lng);
    if (cityId == null) {
      return const Left(OutsideServiceAreaFailure());
    }
    return _busRepository.shareBusLocation(
      routeId: routeId,
      lat: lat,
      lng: lng,
      heading: heading,
      speedKmh: speedKmh,
    );
  }
}
