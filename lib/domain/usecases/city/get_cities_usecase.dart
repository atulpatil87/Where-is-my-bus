import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/city.dart';
import '../../repositories/i_city_repository.dart';

class GetCitiesUseCase {
  final ICityRepository _repository;
  const GetCitiesUseCase(this._repository);

  Future<Either<Failure, List<City>>> call() => _repository.getCities();
}
