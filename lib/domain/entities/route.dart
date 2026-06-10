import 'package:equatable/equatable.dart';

class Route extends Equatable {
  final String id;
  final String routeNumber;
  final String routeName;
  final String shortName;
  final String cityId;
  final String busType; // "AC" | "NonAC" | "Electric" | "Mini"
  final bool isActive;
  final String firstBusTime;
  final String lastBusTime;
  final int frequencyMins;
  final int totalStops;
  final double distanceKm;
  final int durationMins;
  final int fareMin;
  final int fareMax;
  final List<String> stopIds;
  final List<String> operatingDays;
  final List<String> tags;

  const Route({
    required this.id,
    required this.routeNumber,
    required this.routeName,
    required this.shortName,
    required this.cityId,
    required this.busType,
    required this.isActive,
    required this.firstBusTime,
    required this.lastBusTime,
    required this.frequencyMins,
    required this.totalStops,
    required this.distanceKm,
    required this.durationMins,
    required this.fareMin,
    required this.fareMax,
    required this.stopIds,
    required this.operatingDays,
    required this.tags,
  });

  @override
  List<Object?> get props => [id];
}

// Route Finder result entities
class RouteResult extends Equatable {
  final String type; // "direct" | "one_change" | "two_change"
  final List<RouteSegment> segments;
  final int totalDurationMins;
  final int totalFare;
  final int walkDistanceMeters;
  final int totalStops;
  final int crowdLevel;
  final bool isFastest;
  final bool isLeastCrowded;
  final bool isCheapest;

  const RouteResult({
    required this.type,
    required this.segments,
    required this.totalDurationMins,
    required this.totalFare,
    required this.walkDistanceMeters,
    required this.totalStops,
    required this.crowdLevel,
    required this.isFastest,
    required this.isLeastCrowded,
    required this.isCheapest,
  });

  @override
  List<Object?> get props => [type, segments];
}

class RouteSegment extends Equatable {
  final String routeId;
  final String routeNumber;
  final String routeName;
  final String busType;
  final String fromStopId;
  final String fromStopName;
  final String toStopId;
  final String toStopName;
  final int stopCount;
  final int durationMins;
  final int fare;
  final int crowdLevel;

  const RouteSegment({
    required this.routeId,
    required this.routeNumber,
    required this.routeName,
    required this.busType,
    required this.fromStopId,
    required this.fromStopName,
    required this.toStopId,
    required this.toStopName,
    required this.stopCount,
    required this.durationMins,
    required this.fare,
    required this.crowdLevel,
  });

  @override
  List<Object?> get props => [routeId, fromStopId, toStopId];
}
