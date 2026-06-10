import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../models/cell_tower_model.dart';

/// Realtime DB access for the crowd-sourced tower→location map and for
/// publishing tower-derived bus positions.
class TowerRemoteDataSource {
  final FirebaseDatabase _rtdb;
  final _uuid = const Uuid();

  TowerRemoteDataSource(this._rtdb);

  DatabaseReference _fingerprintRef(String cityId, String cellKey) =>
      _rtdb.ref(
        '${FirebaseConstants.rtdbTowerFingerprints}/$cityId/$cellKey',
      );

  Future<TowerFingerprintModel?> getFingerprint(
    String cityId,
    String cellKey,
  ) async {
    final snap = await _fingerprintRef(cityId, cellKey).get();
    if (!snap.exists || snap.value == null) return null;
    final data = Map<String, dynamic>.from(snap.value as Map);
    return TowerFingerprintModel.fromRealtimeDb(cellKey, data);
  }

  /// Reads, folds in the new sample, and writes back — a small read-modify-write
  /// guarded by a transaction so concurrent riders don't clobber the centroid.
  Future<void> upsertFingerprintSample({
    required String cityId,
    required String cellKey,
    required double lat,
    required double lng,
    required String nearestStopId,
    required String nearestStopName,
  }) async {
    final ref = _fingerprintRef(cityId, cellKey);
    await ref.runTransaction((current) {
      final existing = current == null
          ? null
          : TowerFingerprintModel.fromRealtimeDb(
              cellKey, Map<String, dynamic>.from(current as Map));

      final updated = existing == null
          ? TowerFingerprintModel(
              cellKey: cellKey,
              lat: lat,
              lng: lng,
              nearestStopId: nearestStopId,
              nearestStopName: nearestStopName,
              sampleCount: 1,
              lastUpdated: DateTime.now(),
            )
          : existing.withSample(
              sampleLat: lat,
              sampleLng: lng,
              stopId: nearestStopId,
              stopName: nearestStopName,
            );

      return Transaction.success(updated.toRealtimeDb());
    });
  }

  /// Writes a bus position resolved from a tower fingerprint into the same
  /// `live_buses` feed the map already reads.
  Future<void> writeTowerBusLocation({
    required String cityId,
    required String routeId,
    required String routeNumber,
    required double lat,
    required double lng,
    required String nextStopId,
    required String nextStopName,
  }) async {
    final sessionId = 'tower_${_uuid.v4().substring(0, 8)}';
    final ref = _rtdb.ref(
      '${FirebaseConstants.rtdbLiveBuses}/$cityId/$sessionId',
    );
    await ref.set({
      'routeId': routeId,
      'routeNumber': routeNumber,
      'lat': lat,
      'lng': lng,
      'heading': 0.0,
      'speedKmh': 0.0,
      'isLive': true,
      'isCommunity': true,
      'source': 'cell_tower',
      'crowdLevel': 1,
      'nextStopId': nextStopId,
      'nextStopName': nextStopName,
      'lastUpdated': DateTime.now().millisecondsSinceEpoch,
    });
    await ref.onDisconnect().remove();
  }
}
