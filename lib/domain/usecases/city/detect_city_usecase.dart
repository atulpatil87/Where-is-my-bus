import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/services/location_service.dart';
import '../../entities/city.dart';
import '../../repositories/i_city_repository.dart';

/// Runs on the Splash Screen. Gets GPS → matches city → saves preference.
class DetectCityUseCase {
  final ICityRepository _cityRepository;
  final LocationService _locationService;

  const DetectCityUseCase(this._cityRepository, this._locationService);

  Future<Either<Failure, City>> call() async {
    try {
      final position = await _locationService.getCurrentLocation();
      final cityResult = await _cityRepository.detectCityFromLocation(
        position.latitude,
        position.longitude,
      );
      return cityResult.fold(
        (_) => _fallbackToSaved(),
        (city) async {
          await _cityRepository.saveSelectedCity(city.id);
          return Right(city);
        },
      );
    } catch (_) {
      return _fallbackToSaved();
    }
  }

  Future<Either<Failure, City>> _fallbackToSaved() async {
    final savedResult = await _cityRepository.getSavedCityId();
    return savedResult.fold(
      (_) => const Left(NoCitySelectedFailure()),
      (cityId) => _cityRepository.getCityById(cityId),
    );
  }
}
