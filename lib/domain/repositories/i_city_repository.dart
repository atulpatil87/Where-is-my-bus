import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/city.dart';

abstract class ICityRepository {
  Future<Either<Failure, List<City>>> getCities();
  Future<Either<Failure, City>> detectCityFromLocation(double lat, double lng);
  Future<Either<Failure, City>> getCityById(String cityId);
  Future<Either<Failure, void>> saveSelectedCity(String cityId);
  Future<Either<Failure, String>> getSavedCityId();
}
