import 'package:equatable/equatable.dart';

/// A PMPML bus stop as returned by the Chartr routes API.
class PmpmlStopModel extends Equatable {
  final String stopId;
  final String stopName;
  final double lat;
  final double lng;
  final List<String> routeIds;

  const PmpmlStopModel({
    required this.stopId,
    required this.stopName,
    required this.lat,
    required this.lng,
    required this.routeIds,
  });

  factory PmpmlStopModel.fromJson(Map<String, dynamic> json) {
    // Lat/lng may come as num or string
    double parseCoord(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return PmpmlStopModel(
      stopId: (json['stop_id'] ?? json['id'] ?? json['stopId'] ?? '')
          .toString(),
      stopName: (json['stop_name'] ?? json['name'] ?? json['stopName'] ?? '')
          .toString(),
      lat: parseCoord(json['lat'] ?? json['latitude']),
      lng: parseCoord(json['lng'] ?? json['lon'] ?? json['longitude']),
      routeIds: _parseStringList(json['routes'] ?? json['route_ids']),
    );
  }

  static List<String> _parseStringList(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    if (raw is String) return [raw];
    return [];
  }

  Map<String, dynamic> toJson() => {
        'stop_id': stopId,
        'stop_name': stopName,
        'lat': lat,
        'lng': lng,
        'routes': routeIds,
      };

  @override
  List<Object?> get props => [stopId];
}
