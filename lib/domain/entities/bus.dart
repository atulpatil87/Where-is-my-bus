import 'package:equatable/equatable.dart';

enum BusStatus { onTime, delayed, crowded }

class Bus extends Equatable {
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
  final int crowdLevel; // 1-4
  final String crowdLabel;
  final String nextStopId;
  final String nextStopName;
  final int nextStopETAMins;
  final bool isCommunity;
  final DateTime lastUpdated;

  const Bus({
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

  BusStatus get status {
    if (crowdLevel >= 3) return BusStatus.crowded;
    if (nextStopETAMins > 15) return BusStatus.delayed;
    return BusStatus.onTime;
  }

  @override
  List<Object?> get props => [id];
}

class BusArrival extends Equatable {
  final String routeNumber;
  final String routeId;
  final int etaMins;
  final int crowdLevel;

  const BusArrival({
    required this.routeNumber,
    required this.routeId,
    required this.etaMins,
    required this.crowdLevel,
  });

  @override
  List<Object?> get props => [routeId, etaMins];
}
