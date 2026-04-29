import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/route_model.dart';
import '../../models/timetable_model.dart';

class RouteRemoteDataSource {
  final FirebaseFirestore _firestore;

  RouteRemoteDataSource(this._firestore);

  Future<List<RouteModel>> getAllRoutes(String cityId) async {
    try {
      final snap = await _firestore
          .collection(FirebaseConstants.collectionCities)
          .doc(cityId)
          .collection(FirebaseConstants.collectionRoutes)
          .where(FirebaseConstants.fieldIsActive, isEqualTo: true)
          .orderBy(FirebaseConstants.fieldRouteNumber)
          .get();
      return snap.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return RouteModel.fromJson(data);
      }).toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Firestore error');
    }
  }

  Future<RouteModel> getRouteById(String cityId, String routeId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.collectionCities)
          .doc(cityId)
          .collection(FirebaseConstants.collectionRoutes)
          .doc(routeId)
          .get();
      if (!doc.exists) {
        throw NotFoundException(message: 'Route $routeId not found.');
      }
      final data = doc.data()!;
      data['id'] = doc.id;
      return RouteModel.fromJson(data);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Firestore error');
    }
  }

  Future<TimetableModel> getRouteTimetable(
      String cityId, String routeId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.collectionCities)
          .doc(cityId)
          .collection(FirebaseConstants.collectionTimetables)
          .doc(routeId)
          .get();
      if (!doc.exists) {
        throw NotFoundException(
            message: 'Timetable for $routeId not found.');
      }
      return TimetableModel.fromJson(doc.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Firestore error');
    }
  }
}
