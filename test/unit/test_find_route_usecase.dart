import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:busindia/core/errors/failures.dart';
import 'package:busindia/domain/entities/route.dart';
import 'package:busindia/domain/repositories/i_route_repository.dart';
import 'package:busindia/domain/usecases/route/find_route_usecase.dart';

class MockRouteRepository extends Mock implements IRouteRepository {}

void main() {
  late FindRouteUseCase useCase;
  late MockRouteRepository mockRepo;

  setUp(() {
    mockRepo = MockRouteRepository();
    useCase = FindRouteUseCase(mockRepo);
  });

  const cityId = 'pune';
  const fromStop = 'stop_swargate';
  const toStop = 'stop_hinjewadi';

  final fakeDirectResult = const RouteResult(
    type: 'direct',
    segments: [
      RouteSegment(
        routeId: 'route_155',
        routeNumber: '155',
        routeName: 'Swargate - Hinjewadi',
        busType: 'AC',
        fromStopId: fromStop,
        fromStopName: 'Swargate',
        toStopId: toStop,
        toStopName: 'Hinjewadi',
        stopCount: 20,
        durationMins: 50,
        fare: 25,
        crowdLevel: 2,
      ),
    ],
    totalDurationMins: 50,
    totalFare: 25,
    walkDistanceMeters: 200,
    totalStops: 20,
    crowdLevel: 2,
    isFastest: false,
    isLeastCrowded: false,
    isCheapest: false,
  );

  group('FindRouteUseCase', () {
    test('✅ Returns direct route when found, tagged as fastest', () async {
      when(() => mockRepo.findRoutes(
            cityId: cityId,
            fromStopId: fromStop,
            toStopId: toStop,
          )).thenAnswer((_) async => Right([fakeDirectResult]));

      final result = await useCase.call(
        cityId: cityId,
        fromStopId: fromStop,
        toStopId: toStop,
      );

      expect(result.isRight(), true);
      final routes = result.getOrElse(() => []);
      expect(routes.first.type, 'direct');
      // Only result → tagged fastest, cheapest, least crowded
      expect(routes.first.isFastest, true);
    });

    test('✅ Returns empty list when no route found', () async {
      when(() => mockRepo.findRoutes(
            cityId: cityId,
            fromStopId: fromStop,
            toStopId: toStop,
          )).thenAnswer((_) async => const Right([]));

      final result = await useCase.call(
        cityId: cityId,
        fromStopId: fromStop,
        toStopId: toStop,
      );

      expect(result.isRight(), true);
      expect(result.getOrElse(() => []), isEmpty);
    });

    test('✅ Same origin and destination → InvalidInputFailure', () async {
      final result = await useCase.call(
        cityId: cityId,
        fromStopId: fromStop,
        toStopId: fromStop,
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<InvalidInputFailure>()),
        (_) => fail('Should have returned a failure'),
      );
    });

    test('✅ Multiple results are tagged correctly', () async {
      final fast = fakeDirectResult;
      const cheap = RouteResult(
        type: 'one_change',
        segments: [],
        totalDurationMins: 70,
        totalFare: 10,
        walkDistanceMeters: 300,
        totalStops: 25,
        crowdLevel: 1,
        isFastest: false,
        isLeastCrowded: false,
        isCheapest: false,
      );

      when(() => mockRepo.findRoutes(
            cityId: cityId,
            fromStopId: fromStop,
            toStopId: toStop,
          )).thenAnswer((_) async => Right([fast, cheap]));

      final result = await useCase.call(
        cityId: cityId,
        fromStopId: fromStop,
        toStopId: toStop,
      );

      final routes = result.getOrElse(() => []);
      expect(routes.length, 2);
      expect(routes.where((r) => r.isFastest).isNotEmpty, true);
      expect(routes.where((r) => r.isCheapest).isNotEmpty, true);
      expect(routes.where((r) => r.isLeastCrowded).isNotEmpty, true);
    });
  });
}
