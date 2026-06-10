import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user.dart';
import '../../repositories/i_user_repository.dart';

class SignInUseCase {
  final IUserRepository _userRepository;
  const SignInUseCase(this._userRepository);

  Future<Either<Failure, User>> withGoogle() =>
      _userRepository.signInWithGoogle();

  Future<Either<Failure, User>> asGuest() =>
      _userRepository.signInAsGuest();

  Future<Either<Failure, String>> sendOTP(String phone) =>
      _userRepository.sendOTP(phone);

  Future<Either<Failure, User>> verifyOTP(String otp, String phone) =>
      _userRepository.verifyOTP(otp, phone);
}
