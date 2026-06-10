import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/utils/distance_utils.dart';
import '../../models/stop_model.dart';

class StopRemoteDataSource {
  final FirebaseFirestore _firestore;

  StopRemoteDataSource(this._firestore);

  Future<List<StopModel>> getNearbyStops({
    required String cityId,
    required double lat,
    required double lng,
    required double radiusMeters,
  }) async {
    try {
      final snap = await _firestore
          .collection(FirebaseConstants.collectionCities)
          .doc(cityId)
          .collection(FirebaseConstants.collectionStops)
          .get();

      final all = snap.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return StopModel.fromJson(data);
      }).toList();

      return all.where((stop) {
        final dist = DistanceUtils.haversineMeters(lat, lng, stop.lat, stop.lng);
        return dist <= radiusMeters;
      }).toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Firestore error');
    }
  }

  Future<StopModel> getStopById(String cityId, String stopId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.collectionCities)
          .doc(cityId)
          .collection(FirebaseConstants.collectionStops)
          .doc(stopId)
          .get();
      if (!doc.exists) {
        throw NotFoundException(message: 'Stop $stopId not found.');
      }
      final data = doc.data()!;
      data['id'] = doc.id;
      return StopModel.fromJson(data);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Firestore error');
    }
  }

  Future<List<StopModel>> getStopsForRoute(
      String cityId, String routeId) async {
    try {
      final snap = await _firestore
          .collection(FirebaseConstants.collectionCities)
          .doc(cityId)
          .collection(FirebaseConstants.collectionStops)
          .where('routeIds', arrayContains: routeId)
          .get();
      return snap.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return StopModel.fromJson(data);
      }).toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Firestore error');
    }
  }
}
