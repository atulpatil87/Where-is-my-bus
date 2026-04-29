import 'package:equatable/equatable.dart';
import '../../domain/entities/stop.dart';
import '../../domain/entities/bus.dart';

class StopModel extends Equatable {
  final String id;
  final String name;
  final String? localName;
  final String cityId;
  final double lat;
  final double lng;
  final bool isMajorStop;
  final bool hasWaiting;
  final bool hasFacilities;
  final List<String> routeIds;
  final List<String> nearbyLandmarks;

  const StopModel({
    required this.id,
    required this.name,
    this.localName,
    required this.cityId,
    required this.lat,
    required this.lng,
    required this.isMajorStop,
    required this.hasWaiting,
    required this.hasFacilities,
    required this.routeIds,
    required this.nearbyLandmarks,
  });

  factory StopModel.fromJson(Map<String, dynamic> json) {
    final loc = json['location'] as Map<String, dynamic>? ?? {};
    return StopModel(
      id: json['id'] as String,
      name: json['name'] as String,
      localName: json['localName'] as String?,
      cityId: json['cityId'] as String? ?? '',
      lat: (loc['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (loc['lng'] as num?)?.toDouble() ?? 0.0,
      isMajorStop: json['isMajorStop'] as bool? ?? false,
      hasWaiting: json['hasWaiting'] as bool? ?? false,
      hasFacilities: json['hasFacilities'] as bool? ?? false,
      routeIds: List<String>.from(json['routeIds'] as List? ?? []),
      nearbyLandmarks:
          List<String>.from(json['nearbyLandmarks'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'localName': localName,
        'cityId': cityId,
        'location': {'lat': lat, 'lng': lng},
        'isMajorStop': isMajorStop,
        'hasWaiting': hasWaiting,
        'hasFacilities': hasFacilities,
        'routeIds': routeIds,
        'nearbyLandmarks': nearbyLandmarks,
      };

  Stop toEntity({
    double? distanceMeters,
    int? walkingMins,
    BusArrival? nextBus,
  }) =>
      Stop(
        id: id,
        name: name,
        localName: localName,
        cityId: cityId,
        lat: lat,
        lng: lng,
        isMajorStop: isMajorStop,
        hasWaiting: hasWaiting,
        hasFacilities: hasFacilities,
        routeIds: routeIds,
        nearbyLandmarks: nearbyLandmarks,
        distanceMeters: distanceMeters,
        walkingMins: walkingMins,
        nextBus: nextBus,
      );

  @override
  List<Object?> get props => [id];
}
