import 'package:equatable/equatable.dart';

class City extends Equatable {
  final String id;
  final String name;
  final String state;
  final String operatorName;
  final String operatorCode;
  final String primaryColor;
  final String? logoUrl;
  final bool hasLiveTracking;
  final bool isActive;
  final String? apiEndpoint;
  final double lat;
  final double lng;
  final double radiusKm;
  final int totalBuses;
  final int totalRoutes;
  final int totalStops;
  final DateTime updatedAt;

  const City({
    required this.id,
    required this.name,
    required this.state,
    required this.operatorName,
    required this.operatorCode,
    required this.primaryColor,
    this.logoUrl,
    required this.hasLiveTracking,
    required this.isActive,
    this.apiEndpoint,
    required this.lat,
    required this.lng,
    required this.radiusKm,
    required this.totalBuses,
    required this.totalRoutes,
    required this.totalStops,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id];
}
