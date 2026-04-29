import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/errors/failures.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/location_service.dart';
import '../../entities/user.dart';
import '../../repositories/i_bus_repository.dart';
import '../../repositories/i_user_repository.dart';

/// Called from CrowdReportSheet bottom sheet.
class SubmitCrowdReportUseCase {
  final IBusRepository _busRepository;
  final IUserRepository _userRepository;
  final LocationService _locationService;

  const SubmitCrowdReportUseCase(
    this._busRepository,
    this._userRepository,
    this._locationService,
  );

  Future<Either<Failure, void>> call({
    required String busId,
    required String routeId,
    required String cityId,
    required int crowdLevel,
  }) async {
    // 1. Validate crowdLevel
    if (crowdLevel < 1 || crowdLevel > 4) {
      return const Left(
        InvalidInputFailure(message: 'Crowd level must be between 1 and 4.'),
      );
    }

    // 2. Get authenticated user
    final user = await _userRepository.authStateChanges.first;
    if (user == null) {
      return const Left(AuthFailure(message: 'Sign in to submit a report.'));
    }

    // 3. Get location
    late Position position;
    try {
      position = await _locationService.getCurrentLocation();
    } catch (_) {
      return const Left(
        LocationPermissionDeniedFailure(
          message: 'Location needed to submit a crowd report.',
        ),
      );
    }

    final now = DateTime.now();
    final report = CrowdReport(
      busId: busId,
      routeId: routeId,
      cityId: cityId,
      userId: user.id,
      crowdLevel: crowdLevel,
      crowdLabel: _labelFor(crowdLevel),
      lat: position.latitude,
      lng: position.longitude,
      reportedAt: now,
      expiresAt: now.add(
        const Duration(minutes: AppConstants.crowdReportExpiryMins),
      ),
    );

    return _busRepository.submitCrowdReport(report);
  }

  String _labelFor(int level) => switch (level) {
        1 => 'Empty',
        2 => 'Seated',
        3 => 'Standing',
        4 => 'Full',
        _ => 'Unknown',
      };
}
