import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:busindia/core/errors/failures.dart';
import 'package:busindia/core/services/location_service.dart';
import 'package:busindia/domain/entities/city.dart';
import 'package:busindia/domain/repositories/i_city_repository.dart';
import 'package:busindia/domain/usecases/city/detect_city_usecase.dart';
import 'package:geolocator/geolocator.dart';

class MockCityRepository extends Mock implements ICityRepository {}

class MockLocationService extends Mock implements LocationService {}

Position _fakePos(double lat, double lng) => Position(
      latitude: lat,
      longitude: lng,
      altitude: 0,
      accuracy: 5,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      timestamp: DateTime.now(),
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );

final _pune = City(
  id: 'pune',
  name: 'Pune',
  state: 'Maharashtra',
  operatorName: 'PMPML',
  operatorCode: 'pmpml',
  primaryColor: '#E65100',
  hasLiveTracking: true,
  isActive: true,
  lat: 18.5204,
  lng: 73.8567,
  radiusKm: 40,
  totalBuses: 2100,
  totalRoutes: 210,
  totalStops: 1850,
  updatedAt: DateTime.now(),
);

void main() {
  late DetectCityUseCase useCase;
  late MockCityRepository mockRepo;
  late MockLocationService mockLocation;

  setUp(() {
    mockRepo = MockCityRepository();
    mockLocation = MockLocationService();
    useCase = DetectCityUseCase(mockRepo, mockLocation);
  });

  group('DetectCityUseCase', () {
    test('✅ GPS inside Pune → returns Pune', () async {
      when(() => mockLocation.getCurrentLocation())
          .thenAnswer((_) async => _fakePos(18.5204, 73.8567));
      when(() => mockRepo.detectCityFromLocation(18.5204, 73.8567))
          .thenAnswer((_) async => Right(_pune));
      when(() => mockRepo.saveSelectedCity('pune'))
          .thenAnswer((_) async => const Right(null));

      final result = await useCase.call();
      expect(result.isRight(), true);
      expect(result.getOrElse(() => _pune).id, 'pune');
    });

    test('✅ GPS outside all cities → NoCitySelectedFailure', () async {
      when(() => mockLocation.getCurrentLocation())
          .thenAnswer((_) async => _fakePos(0.0, 0.0));
      when(() => mockRepo.detectCityFromLocation(0.0, 0.0))
          .thenAnswer((_) async => const Left(OutsideServiceAreaFailure()));
      when(() => mockRepo.getSavedCityId())
          .thenAnswer((_) async => const Left(NoCitySelectedFailure()));

      final result = await useCase.call();
      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, isA<NoCitySelectedFailure>()),
        (_) => fail('Should be failure'),
      );
    });

    test('✅ GPS permission denied → fallback to saved city', () async {
      // Throw a generic Exception (LocationService wraps real exceptions)
      when(() => mockLocation.getCurrentLocation())
          .thenThrow(Exception('Location permission denied'));
      when(() => mockRepo.getSavedCityId())
          .thenAnswer((_) async => const Right('pune'));
      when(() => mockRepo.getCityById('pune'))
          .thenAnswer((_) async => Right(_pune));

      final result = await useCase.call();
      expect(result.isRight(), true);
      expect(result.getOrElse(() => _pune).id, 'pune');
    });
  });
}
