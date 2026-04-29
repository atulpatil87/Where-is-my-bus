import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../models/bus_model.dart';

class BusRemoteDataSource {
  final FirebaseDatabase _rtdb;
  final _uuid = const Uuid();

  BusRemoteDataSource(this._rtdb);

  Stream<List<BusModel>> getLiveBuses(String cityId) {
    final ref = _rtdb.ref('${FirebaseConstants.rtdbLiveBuses}/$cityId');
    return ref.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      final staleThreshold = DateTime.now().subtract(
        const Duration(seconds: AppConstants.liveBusStaleThresholdSecs),
      );
      return data.entries
          .map((e) {
            final busData = Map<String, dynamic>.from(e.value as Map);
            return BusModel.fromRealtimeDb(e.key.toString(), busData);
          })
          .where((bus) => bus.lastUpdated.isAfter(staleThreshold))
          .toList();
    });
  }

  Stream<List<BusModel>> getLiveBusesByRoute(String cityId, String routeId) {
    return getLiveBuses(cityId).map(
      (buses) => buses.where((b) => b.routeId == routeId).toList(),
    );
  }

  Future<void> writeCommunityBusLocation({
    required String cityId,
    required String routeId,
    required double lat,
    required double lng,
    required double heading,
    required double speedKmh,
  }) async {
    final sessionId = 'comm_${_uuid.v4().substring(0, 8)}';
    final ref = _rtdb.ref(
      '${FirebaseConstants.rtdbLiveBuses}/$cityId/$sessionId',
    );
    await ref.set({
      'routeId': routeId,
      'lat': lat,
      'lng': lng,
      'heading': heading,
      'speedKmh': speedKmh,
      'isLive': true,
      'isCommunity': true,
      'crowdLevel': 1,
      'lastUpdated': DateTime.now().millisecondsSinceEpoch,
    });
    await ref.onDisconnect().remove();
  }
}
