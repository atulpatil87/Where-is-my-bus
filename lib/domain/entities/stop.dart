import 'package:equatable/equatable.dart';
import 'bus.dart';

class Stop extends Equatable {
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

  // Computed fields (populated after GPS query)
  final double? distanceMeters;
  final int? walkingMins;
  final BusArrival? nextBus;

  const Stop({
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
    this.distanceMeters,
    this.walkingMins,
    this.nextBus,
  });

  Stop copyWith({
    double? distanceMeters,
    int? walkingMins,
    BusArrival? nextBus,
  }) {
    return Stop(
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
      distanceMeters: distanceMeters ?? this.distanceMeters,
      walkingMins: walkingMins ?? this.walkingMins,
      nextBus: nextBus ?? this.nextBus,
    );
  }

  @override
  List<Object?> get props => [id];
}
