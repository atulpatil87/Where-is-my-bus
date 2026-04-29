import 'package:flutter_test/flutter_test.dart';

import 'package:busindia/data/models/route_model.dart';

void main() {
  final sampleJson = {
    'id': 'route_155',
    'routeNumber': '155',
    'routeName': 'Swargate - Hinjewadi Phase 3',
    'shortName': 'Swargate-Hinjewadi',
    'cityId': 'pune',
    'busType': 'AC',
    'isActive': true,
    'firstBusTime': '05:30',
    'lastBusTime': '23:00',
    'frequencyMins': 12,
    'totalStops': 33,
    'distanceKm': 28.5,
    'durationMins': 50,
    'fareMin': 10,
    'fareMax': 35,
    'stopIds': ['stop_swargate', 'stop_pune_stn', 'stop_hinjewadi'],
    'operatingDays': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    'tags': ['airport', 'IT park'],
  };

  group('RouteModel', () {
    test('✅ fromJson() parses correctly', () {
      final model = RouteModel.fromJson(sampleJson);
      expect(model.id, 'route_155');
      expect(model.routeNumber, '155');
      expect(model.busType, 'AC');
      expect(model.fareMin, 10);
      expect(model.fareMax, 35);
      expect(model.stopIds.length, 3);
      expect(model.tags.contains('IT park'), true);
    });

    test('✅ toJson() serializes correctly', () {
      final model = RouteModel.fromJson(sampleJson);
      final json = model.toJson();
      expect(json['routeNumber'], '155');
      expect(json['distanceKm'], 28.5);
      expect(json['operatingDays'], contains('Mon'));
    });

    test('✅ copyWith() creates new instance with updated fields', () {
      final original = RouteModel.fromJson(sampleJson);
      final copy = original.copyWith(isActive: false, frequencyMins: 20);
      expect(copy.isActive, false);
      expect(copy.frequencyMins, 20);
      // Original unchanged
      expect(original.isActive, true);
      expect(original.frequencyMins, 12);
    });

    test('✅ toEntity() maps all fields to Route entity', () {
      final model = RouteModel.fromJson(sampleJson);
      final entity = model.toEntity();
      expect(entity.routeNumber, model.routeNumber);
      expect(entity.firstBusTime, '05:30');
      expect(entity.stopIds.length, model.stopIds.length);
    });
  });
}
