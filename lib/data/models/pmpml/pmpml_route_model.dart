import 'package:equatable/equatable.dart';
import 'pmpml_stop_model.dart';

/// A PMPML route as returned by /v1/get-combined-data.
class PmpmlRouteModel extends Equatable {
  final String routeId;
  final String routeNumber;
  final String routeLongName;
  final String routeShortName;
  final String busType; // 'AC', 'NonAC', 'Electric', 'Mini', etc.
  final String firstBusTime;
  final String lastBusTime;
  final int frequencyMins;
  final int fareMin;
  final int fareMax;
  final List<String> stopIds;
  final List<PmpmlStopModel> stops; // embedded if returned inline

  const PmpmlRouteModel({
    required this.routeId,
    required this.routeNumber,
    required this.routeLongName,
    required this.routeShortName,
    required this.busType,
    required this.firstBusTime,
    required this.lastBusTime,
    required this.frequencyMins,
    required this.fareMin,
    required this.fareMax,
    required this.stopIds,
    required this.stops,
  });

  factory PmpmlRouteModel.fromJson(Map<String, dynamic> json) {
    List<PmpmlStopModel> parseStops(dynamic raw) {
      if (raw == null || raw is! List) return [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map(PmpmlStopModel.fromJson)
          .toList();
    }

    return PmpmlRouteModel(
      routeId: (json['route_id'] ?? json['id'] ?? json['routeId'] ?? '')
          .toString(),
      routeNumber:
          (json['route_number'] ?? json['routeNumber'] ?? json['number'] ?? '')
              .toString(),
      routeLongName:
          (json['route_long_name'] ?? json['routeLongName'] ?? json['name'] ?? '')
              .toString(),
      routeShortName:
          (json['route_short_name'] ?? json['routeShortName'] ?? json['short_name'] ?? '')
              .toString(),
      busType:
          (json['bus_type'] ?? json['busType'] ?? json['type'] ?? 'NonAC')
              .toString(),
      firstBusTime:
          (json['first_bus_time'] ?? json['firstBusTime'] ?? '05:30')
              .toString(),
      lastBusTime:
          (json['last_bus_time'] ?? json['lastBusTime'] ?? '23:00').toString(),
      frequencyMins:
          (json['frequency_mins'] ?? json['frequencyMins'] ?? json['frequency'] ?? 15)
              is num
              ? (json['frequency_mins'] ??
                          json['frequencyMins'] ??
                          json['frequency'] ??
                          15)
                      .toInt()
              : 15,
      fareMin: (json['fare_min'] ?? json['fareMin'] ?? json['min_fare'] ?? 0)
              is num
          ? (json['fare_min'] ?? json['fareMin'] ?? json['min_fare'] ?? 0)
              .toInt()
          : 0,
      fareMax:
          (json['fare_max'] ?? json['fareMax'] ?? json['max_fare'] ?? 0) is num
              ? (json['fare_max'] ?? json['fareMax'] ?? json['max_fare'] ?? 0)
                  .toInt()
              : 0,
      stopIds: _parseStringList(json['stop_ids'] ?? json['stopIds'] ?? json['stops']),
      stops: parseStops(json['stop_details'] ?? json['stops_data']),
    );
  }

  static List<String> _parseStringList(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return [];
  }

  Map<String, dynamic> toJson() => {
        'route_id': routeId,
        'route_number': routeNumber,
        'route_long_name': routeLongName,
        'route_short_name': routeShortName,
        'bus_type': busType,
        'first_bus_time': firstBusTime,
        'last_bus_time': lastBusTime,
        'frequency_mins': frequencyMins,
        'fare_min': fareMin,
        'fare_max': fareMax,
        'stop_ids': stopIds,
      };

  @override
  List<Object?> get props => [routeId];
}
