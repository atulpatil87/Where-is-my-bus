import 'package:dartz/dartz.dart';
import '../../core/constants/city_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/city.dart';
import '../../domain/repositories/i_city_repository.dart';
import '../datasources/remote/city_remote_datasource.dart';
import '../datasources/local/local_datasources.dart';

class CityRepositoryImpl implements ICityRepository {
  final CityRemoteDataSource _remote;
  final CityLocalDataSource _local;

  CityRepositoryImpl(this._remote, this._local);

  @override
  Future<Either<Failure, List<City>>> getCities() async {
    try {
      // Try local cache first
      try {
        final cached = await _local.getCachedCities();
        return Right(cached.map((m) => m.toEntity()).toList());
      } catch (_) {}

      // Fetch from Firestore
      final models = await _remote.getCities();
      await _local.cacheCities(models);
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, City>> detectCityFromLocation(
      double lat, double lng) async {
    final config = CityConstants.findByCoordinates(lat, lng);
    if (config == null) return const Left(OutsideServiceAreaFailure());
    return getCityById(config.id);
  }

  @override
  Future<Either<Failure, City>> getCityById(String cityId) async {
    try {
      final model = await _remote.getCityById(cityId);
      return Right(model.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveSelectedCity(String cityId) async {
    try {
      await _local.saveSelectedCityId(cityId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getSavedCityId() async {
    try {
      final id = await _local.getSelectedCityId();
      if (id == null) return const Left(NoCitySelectedFailure());
      return Right(id);
    } catch (e) {
      return const Left(NoCitySelectedFailure());
    }
  }
}
