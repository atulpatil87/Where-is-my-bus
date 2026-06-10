import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user.dart';
import '../../repositories/i_user_repository.dart';

class GetUserStatsUseCase {
  final IUserRepository _repository;
  const GetUserStatsUseCase(this._repository);

  Future<Either<Failure, UserStats>> call(String userId) =>
      _repository.getUserStats(userId);
}
