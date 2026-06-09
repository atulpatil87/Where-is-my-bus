import '../../domain/entities/cell_tower.dart';

/// RTDB serialization for a crowd-learned tower fingerprint.
class TowerFingerprintModel {
  final String cellKey;
  final double lat;
  final double lng;
  final String nearestStopId;
  final String nearestStopName;
  final int sampleCount;
  final DateTime lastUpdated;

  const TowerFingerprintModel({
    required this.cellKey,
    required this.lat,
    required this.lng,
    required this.nearestStopId,
    required this.nearestStopName,
    required this.sampleCount,
    required this.lastUpdated,
  });

  factory TowerFingerprintModel.fromRealtimeDb(
    String cellKey,
    Map<String, dynamic> data,
  ) {
    return TowerFingerprintModel(
      cellKey: cellKey,
      lat: (data['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (data['lng'] as num?)?.toDouble() ?? 0.0,
      nearestStopId: data['nearestStopId'] as String? ?? '',
      nearestStopName: data['nearestStopName'] as String? ?? '',
      sampleCount: (data['sampleCount'] as num?)?.toInt() ?? 0,
      lastUpdated: data['lastUpdated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (data['lastUpdated'] as num).toInt())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toRealtimeDb() => {
        'lat': lat,
        'lng': lng,
        'nearestStopId': nearestStopId,
        'nearestStopName': nearestStopName,
        'sampleCount': sampleCount,
        'lastUpdated': lastUpdated.millisecondsSinceEpoch,
      };

  /// Folds a fresh GPS/stop sample into the running centroid, so a tower's
  /// position converges as more riders pass it.
  TowerFingerprintModel withSample({
    required double sampleLat,
    required double sampleLng,
    required String stopId,
    required String stopName,
  }) {
    final n = sampleCount;
    final newLat = (lat * n + sampleLat) / (n + 1);
    final newLng = (lng * n + sampleLng) / (n + 1);
    return TowerFingerprintModel(
      cellKey: cellKey,
      lat: newLat,
      lng: newLng,
      nearestStopId: stopId,
      nearestStopName: stopName,
      sampleCount: n + 1,
      lastUpdated: DateTime.now(),
    );
  }

  TowerFingerprint toEntity() => TowerFingerprint(
        cellKey: cellKey,
        lat: lat,
        lng: lng,
        nearestStopId: nearestStopId,
        nearestStopName: nearestStopName,
        sampleCount: sampleCount,
        lastUpdated: lastUpdated,
      );
}
