import 'package:dartz/dartz.dart';
import 'package:kalyanboss/features/auth/domain/entities/verify_otp_entity.dart';
import 'package:kalyanboss/utils/api/api_error.dart';
import 'package:kalyanboss/utils/api/api_result.dart';
import '../../data/repository/auth_repository_impl.dart';


class LoginUseCase {
  final AuthRepositoryImpl authRepository;

  LoginUseCase({required this.authRepository});

  Future<Either<Result<VerifyOtpEntity>, ApiError>>call(Map<String,dynamic> data) async {
    return await authRepository.login(data);
  }
}