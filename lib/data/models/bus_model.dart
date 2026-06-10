import 'package:equatable/equatable.dart';
import '../../domain/entities/bus.dart';

class BusModel extends Equatable {
  final String id;
  final String routeId;
  final String routeNumber;
  final String cityId;
  final String vehicleNumber;
  final double lat;
  final double lng;
  final double heading;
  final double speedKmh;
  final bool isLive;
  final int crowdLevel;
  final String crowdLabel;
  final String nextStopId;
  final String nextStopName;
  final int nextStopETAMins;
  final bool isCommunity;
  final DateTime lastUpdated;

  const BusModel({
    required this.id,
    required this.routeId,
    required this.routeNumber,
    required this.cityId,
    required this.vehicleNumber,
    required this.lat,
    required this.lng,
    required this.heading,
    required this.speedKmh,
    required this.isLive,
    required this.crowdLevel,
    required this.crowdLabel,
    required this.nextStopId,
    required this.nextStopName,
    required this.nextStopETAMins,
    required this.isCommunity,
    required this.lastUpdated,
  });

  factory BusModel.fromRealtimeDb(String id, Map<String, dynamic> data) {
    final crowdLevel = (data['crowdLevel'] as num?)?.toInt() ?? 1;
    return BusModel(
      id: id,
      routeId: data['routeId'] as String? ?? '',
      routeNumber: data['routeNumber'] as String? ?? '',
      cityId: data['cityId'] as String? ?? '',
      vehicleNumber: data['vehicleNumber'] as String? ?? '',
      lat: (data['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (data['lng'] as num?)?.toDouble() ?? 0.0,
      heading: (data['heading'] as num?)?.toDouble() ?? 0.0,
      speedKmh: (data['speedKmh'] as num?)?.toDouble() ?? 0.0,
      isLive: data['isLive'] as bool? ?? true,
      crowdLevel: crowdLevel,
      crowdLabel: _labelFor(crowdLevel),
      nextStopId: data['nextStopId'] as String? ?? '',
      nextStopName: data['nextStopName'] as String? ?? '',
      nextStopETAMins: (data['nextStopETA'] as num?)?.toInt() ?? 0,
      isCommunity: data['isCommunity'] as bool? ?? false,
      lastUpdated: data['lastUpdated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (data['lastUpdated'] as num).toInt())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toRealtimeDb() => {
        'routeId': routeId,
        'routeNumber': routeNumber,
        'vehicleNumber': vehicleNumber,
        'lat': lat,
        'lng': lng,
        'heading': heading,
        'speedKmh': speedKmh,
        'isLive': isLive,
        'crowdLevel': crowdLevel,
        'nextStopId': nextStopId,
        'nextStopETA': nextStopETAMins,
        'isCommunity': isCommunity,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      };

  BusModel copyWith({
    double? lat,
    double? lng,
    int? crowdLevel,
    int? nextStopETAMins,
    DateTime? lastUpdated,
  }) {
    final cl = crowdLevel ?? this.crowdLevel;
    return BusModel(
      id: id,
      routeId: routeId,
      routeNumber: routeNumber,
      cityId: cityId,
      vehicleNumber: vehicleNumber,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      heading: heading,
      speedKmh: speedKmh,
      isLive: isLive,
      crowdLevel: cl,
      crowdLabel: _labelFor(cl),
      nextStopId: nextStopId,
      nextStopName: nextStopName,
      nextStopETAMins: nextStopETAMins ?? this.nextStopETAMins,
      isCommunity: isCommunity,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Bus toEntity() => Bus(
        id: id,
        routeId: routeId,
        routeNumber: routeNumber,
        cityId: cityId,
        vehicleNumber: vehicleNumber,
        lat: lat,
        lng: lng,
        heading: heading,
        speedKmh: speedKmh,
        isLive: isLive,
        crowdLevel: crowdLevel,
        crowdLabel: crowdLabel,
        nextStopId: nextStopId,
        nextStopName: nextStopName,
        nextStopETAMins: nextStopETAMins,
        isCommunity: isCommunity,
        lastUpdated: lastUpdated,
      );

  static String _labelFor(int level) => switch (level) {
        1 => 'Low',
        2 => 'Medium',
        3 => 'High',
        4 => 'Very High',
        _ => 'Unknown',
      };

  @override
  List<Object?> get props => [id];
}
