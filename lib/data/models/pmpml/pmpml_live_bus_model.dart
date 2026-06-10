import 'package:equatable/equatable.dart';

/// A live bus position as returned by /buses-on-route.
class PmpmlLiveBusModel extends Equatable {
  final String busId;
  final String busNumber;
  final String routeId;
  final String routeNumber;
  final double lat;
  final double lng;
  final double heading;
  final double speedKmh;
  final int crowdLevel; // 1=low 2=medium 3=high
  final bool isLive;
  final DateTime lastUpdated;
  final int? etaMinutes; // null if unknown

  const PmpmlLiveBusModel({
    required this.busId,
    required this.busNumber,
    required this.routeId,
    required this.routeNumber,
    required this.lat,
    required this.lng,
    required this.heading,
    required this.speedKmh,
    required this.crowdLevel,
    required this.isLive,
    required this.lastUpdated,
    this.etaMinutes,
  });

  factory PmpmlLiveBusModel.fromJson(Map<String, dynamic> json) {
    double parseCoord(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    DateTime parseTime(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      return DateTime.now();
    }

    return PmpmlLiveBusModel(
      busId: (json['bus_id'] ?? json['id'] ?? json['vehicleId'] ?? '').toString(),
      busNumber: (json['bus_number'] ?? json['busNumber'] ?? json['vehicleNumber'] ?? '').toString(),
      routeId: (json['route_id'] ?? json['routeId'] ?? '').toString(),
      routeNumber: (json['route_number'] ?? json['routeNumber'] ?? json['route'] ?? '').toString(),
      lat: parseCoord(json['lat'] ?? json['latitude']),
      lng: parseCoord(json['lng'] ?? json['lon'] ?? json['longitude']),
      heading: parseCoord(json['heading'] ?? json['bearing'] ?? 0),
      speedKmh: parseCoord(json['speed_kmh'] ?? json['speedKmh'] ?? json['speed'] ?? 0),
      crowdLevel: (json['crowd_level'] ?? json['crowdLevel'] ?? json['occupancy'] ?? 1) is num
          ? (json['crowd_level'] ?? json['crowdLevel'] ?? json['occupancy'] ?? 1).toInt()
          : 1,
      isLive: json['is_live'] as bool? ?? json['isLive'] as bool? ?? true,
      lastUpdated: parseTime(json['last_updated'] ?? json['lastUpdated'] ?? json['timestamp']),
      etaMinutes: (json['eta_minutes'] ?? json['etaMinutes'] ?? json['eta']) is num
          ? (json['eta_minutes'] ?? json['etaMinutes'] ?? json['eta']).toInt()
          : null,
    );
  }

  bool get isStale =>
      DateTime.now().difference(lastUpdated).inMinutes > 3;

  String get crowdLabel {
    switch (crowdLevel) {
      case 1:
        return 'Low';
      case 2:
        return 'Medium';
      case 3:
        return 'High';
      default:
        return 'Unknown';
    }
  }

  @override
  List<Object?> get props => [busId];
}
