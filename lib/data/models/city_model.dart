import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/city.dart';

class CityModel extends Equatable {
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

  const CityModel({
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

  factory CityModel.fromJson(Map<String, dynamic> json) {
    final coords = json['coordinates'] as Map<String, dynamic>? ?? {};
    final stats = json['stats'] as Map<String, dynamic>? ?? {};
    return CityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      state: json['state'] as String? ?? '',
      operatorName: json['operatorName'] as String? ?? '',
      operatorCode: json['operatorCode'] as String? ?? '',
      primaryColor: json['primaryColor'] as String? ?? '#E65100',
      logoUrl: json['logoUrl'] as String?,
      hasLiveTracking: json['hasLiveTracking'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      apiEndpoint: json['apiEndpoint'] as String?,
      lat: (coords['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (coords['lng'] as num?)?.toDouble() ?? 0.0,
      radiusKm: (coords['radius'] as num?)?.toDouble() ?? 40.0,
      totalBuses: (stats['totalBuses'] as num?)?.toInt() ?? 0,
      totalRoutes: (stats['totalRoutes'] as num?)?.toInt() ?? 0,
      totalStops: (stats['totalStops'] as num?)?.toInt() ?? 0,
      updatedAt: (json['updatedAt'] is Timestamp)
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'state': state,
        'operatorName': operatorName,
        'operatorCode': operatorCode,
        'primaryColor': primaryColor,
        'logoUrl': logoUrl,
        'hasLiveTracking': hasLiveTracking,
        'isActive': isActive,
        'apiEndpoint': apiEndpoint,
        'coordinates': {'lat': lat, 'lng': lng, 'radius': radiusKm},
        'stats': {
          'totalBuses': totalBuses,
          'totalRoutes': totalRoutes,
          'totalStops': totalStops,
        },
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  CityModel copyWith({
    String? name,
    bool? hasLiveTracking,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return CityModel(
      id: id,
      name: name ?? this.name,
      state: state,
      operatorName: operatorName,
      operatorCode: operatorCode,
      primaryColor: primaryColor,
      logoUrl: logoUrl,
      hasLiveTracking: hasLiveTracking ?? this.hasLiveTracking,
      isActive: isActive ?? this.isActive,
      apiEndpoint: apiEndpoint,
      lat: lat,
      lng: lng,
      radiusKm: radiusKm,
      totalBuses: totalBuses,
      totalRoutes: totalRoutes,
      totalStops: totalStops,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  City toEntity() => City(
        id: id,
        name: name,
        state: state,
        operatorName: operatorName,
        operatorCode: operatorCode,
        primaryColor: primaryColor,
        logoUrl: logoUrl,
        hasLiveTracking: hasLiveTracking,
        isActive: isActive,
        apiEndpoint: apiEndpoint,
        lat: lat,
        lng: lng,
        radiusKm: radiusKm,
        totalBuses: totalBuses,
        totalRoutes: totalRoutes,
        totalStops: totalStops,
        updatedAt: updatedAt,
      );

  @override
  List<Object?> get props => [id];
}
