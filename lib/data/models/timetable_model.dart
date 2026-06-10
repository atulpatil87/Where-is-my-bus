import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/timetable.dart';

class TimetableStopModel extends Equatable {
  final String stopId;
  final String stopName;
  final int sequence;
  final List<String> scheduledTimes;
  final int fareFromStart;
  final bool isMajorStop;

  const TimetableStopModel({
    required this.stopId,
    required this.stopName,
    required this.sequence,
    required this.scheduledTimes,
    required this.fareFromStart,
    required this.isMajorStop,
  });

  factory TimetableStopModel.fromJson(Map<String, dynamic> json) =>
      TimetableStopModel(
        stopId: json['stopId'] as String,
        stopName: json['stopName'] as String,
        sequence: (json['sequence'] as num).toInt(),
        scheduledTimes:
            List<String>.from(json['scheduledTimes'] as List? ?? []),
        fareFromStart: (json['fareFromStart'] as num?)?.toInt() ?? 0,
        isMajorStop: json['isMajorStop'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'stopId': stopId,
        'stopName': stopName,
        'sequence': sequence,
        'scheduledTimes': scheduledTimes,
        'fareFromStart': fareFromStart,
        'isMajorStop': isMajorStop,
      };

  TimetableStop toEntity() => TimetableStop(
        stopId: stopId,
        stopName: stopName,
        sequence: sequence,
        scheduledTimes: scheduledTimes,
        fareFromStart: fareFromStart,
        isMajorStop: isMajorStop,
      );

  @override
  List<Object?> get props => [stopId, sequence];
}

class TimetableModel extends Equatable {
  final String routeId;
  final String cityId;
  final int version;
  final DateTime lastUpdated;
  final List<TimetableStopModel> weekday;
  final List<TimetableStopModel> saturday;
  final List<TimetableStopModel> sunday;

  const TimetableModel({
    required this.routeId,
    required this.cityId,
    required this.version,
    required this.lastUpdated,
    required this.weekday,
    required this.saturday,
    required this.sunday,
  });

  factory TimetableModel.fromJson(Map<String, dynamic> json) {
    List<TimetableStopModel> _parseStops(dynamic raw) {
      if (raw == null) return [];
      final list = (raw as Map<String, dynamic>)['stops'] as List? ?? [];
      return list
          .map((e) =>
              TimetableStopModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return TimetableModel(
      routeId: json['routeId'] as String,
      cityId: json['cityId'] as String? ?? '',
      version: (json['version'] as num?)?.toInt() ?? 1,
      lastUpdated: (json['lastUpdated'] is Timestamp)
          ? (json['lastUpdated'] as Timestamp).toDate()
          : DateTime.now(),
      weekday: _parseStops(json['weekday']),
      saturday: _parseStops(json['saturday']),
      sunday: _parseStops(json['sunday']),
    );
  }

  Map<String, dynamic> toJson() => {
        'routeId': routeId,
        'cityId': cityId,
        'version': version,
        'lastUpdated': Timestamp.fromDate(lastUpdated),
        'weekday': {'stops': weekday.map((s) => s.toJson()).toList()},
        'saturday': {'stops': saturday.map((s) => s.toJson()).toList()},
        'sunday': {'stops': sunday.map((s) => s.toJson()).toList()},
      };

  Timetable toEntity() => Timetable(
        routeId: routeId,
        cityId: cityId,
        version: version,
        lastUpdated: lastUpdated,
        schedule: {
          DayType.weekday: weekday.map((s) => s.toEntity()).toList(),
          DayType.saturday: saturday.map((s) => s.toEntity()).toList(),
          DayType.sunday: sunday.map((s) => s.toEntity()).toList(),
        },
      );

  @override
  List<Object?> get props => [routeId, cityId, version];
}
