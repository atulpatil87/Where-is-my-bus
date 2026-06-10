import 'package:equatable/equatable.dart';
import '../../domain/entities/route.dart';

class RouteModel extends Equatable {
  final String id;
  final String routeNumber;
  final String routeName;
  final String shortName;
  final String cityId;
  final String busType;
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

  const RouteModel({
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

  factory RouteModel.fromJson(Map<String, dynamic> json) => RouteModel(
        id: json['id'] as String,
        routeNumber: json['routeNumber'] as String,
        routeName: json['routeName'] as String? ?? '',
        shortName: json['shortName'] as String? ?? '',
        cityId: json['cityId'] as String? ?? '',
        busType: json['busType'] as String? ?? 'NonAC',
        isActive: json['isActive'] as bool? ?? true,
        firstBusTime: json['firstBusTime'] as String? ?? '05:30',
        lastBusTime: json['lastBusTime'] as String? ?? '23:00',
        frequencyMins: (json['frequencyMins'] as num?)?.toInt() ?? 15,
        totalStops: (json['totalStops'] as num?)?.toInt() ?? 0,
        distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
        durationMins: (json['durationMins'] as num?)?.toInt() ?? 0,
        fareMin: (json['fareMin'] as num?)?.toInt() ?? 0,
        fareMax: (json['fareMax'] as num?)?.toInt() ?? 0,
        stopIds: List<String>.from(json['stopIds'] as List? ?? []),
        operatingDays:
            List<String>.from(json['operatingDays'] as List? ?? []),
        tags: List<String>.from(json['tags'] as List? ?? []),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'routeNumber': routeNumber,
        'routeName': routeName,
        'shortName': shortName,
        'cityId': cityId,
        'busType': busType,
        'isActive': isActive,
        'firstBusTime': firstBusTime,
        'lastBusTime': lastBusTime,
        'frequencyMins': frequencyMins,
        'totalStops': totalStops,
        'distanceKm': distanceKm,
        'durationMins': durationMins,
        'fareMin': fareMin,
        'fareMax': fareMax,
        'stopIds': stopIds,
        'operatingDays': operatingDays,
        'tags': tags,
      };

  RouteModel copyWith({bool? isActive, int? frequencyMins}) => RouteModel(
        id: id,
        routeNumber: routeNumber,
        routeName: routeName,
        shortName: shortName,
        cityId: cityId,
        busType: busType,
        isActive: isActive ?? this.isActive,
        firstBusTime: firstBusTime,
        lastBusTime: lastBusTime,
        frequencyMins: frequencyMins ?? this.frequencyMins,
        totalStops: totalStops,
        distanceKm: distanceKm,
        durationMins: durationMins,
        fareMin: fareMin,
        fareMax: fareMax,
        stopIds: stopIds,
        operatingDays: operatingDays,
        tags: tags,
      );

  Route toEntity() => Route(
        id: id,
        routeNumber: routeNumber,
        routeName: routeName,
        shortName: shortName,
        cityId: cityId,
        busType: busType,
        isActive: isActive,
        firstBusTime: firstBusTime,
        lastBusTime: lastBusTime,
        frequencyMins: frequencyMins,
        totalStops: totalStops,
        distanceKm: distanceKm,
        durationMins: durationMins,
        fareMin: fareMin,
        fareMax: fareMax,
        stopIds: stopIds,
        operatingDays: operatingDays,
        tags: tags,
      );

  @override
  List<Object?> get props => [id];
}
