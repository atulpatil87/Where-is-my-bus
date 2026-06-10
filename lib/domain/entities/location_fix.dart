import 'package:equatable/equatable.dart';

enum LocationSource { gps, bluetooth, cellTower }

/// A resolved location reading, tagged with where it came from.
/// When [source] is [LocationSource.bluetooth], the coordinates were
/// derived from the closest nearby peer's broadcast (GPS was unavailable).
class LocationFix extends Equatable {
  final double lat;
  final double lng;

  /// Accuracy in metres. For Bluetooth fixes this is the estimated
  /// distance to the peer that supplied the location.
  final double accuracy;
  final LocationSource source;
  final DateTime timestamp;

  const LocationFix({
    required this.lat,
    required this.lng,
    required this.accuracy,
    required this.source,
    required this.timestamp,
  });

  bool get isFromBluetooth => source == LocationSource.bluetooth;
  bool get isFromCellTower => source == LocationSource.cellTower;

  @override
  List<Object?> get props => [lat, lng, source, timestamp];
}
