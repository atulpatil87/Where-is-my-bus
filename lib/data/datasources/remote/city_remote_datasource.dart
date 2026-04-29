import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/city_model.dart';

class CityRemoteDataSource {
  final FirebaseFirestore _firestore;

  CityRemoteDataSource(this._firestore);

  Future<List<CityModel>> getCities() async {
    try {
      final snap = await _firestore
          .collection(FirebaseConstants.collectionCities)
          .where(FirebaseConstants.fieldIsActive, isEqualTo: true)
          .get();
      return snap.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return CityModel.fromJson(data);
      }).toList();
    } on FirebaseException catch (e) {
      throw ServerException(
          message: e.message ?? 'Firestore error',
          statusCode: e.code.hashCode);
    }
  }

  Future<CityModel> getCityById(String cityId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.collectionCities)
          .doc(cityId)
          .get();
      if (!doc.exists) {
        throw NotFoundException(message: 'City $cityId not found.');
      }
      final data = doc.data()!;
      data['id'] = doc.id;
      return CityModel.fromJson(data);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Firestore error');
    }
  }
}
