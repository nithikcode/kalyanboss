import 'package:dartz/dartz.dart';
import 'package:kalyanboss/features/auth/domain/entities/signup_entity.dart';
import 'package:kalyanboss/utils/api/api_error.dart';
import 'package:kalyanboss/utils/api/api_result.dart';

import '../../data/repository/auth_repository_impl.dart';

class SignUpUseCase {
  final AuthRepositoryImpl authRepository;

  SignUpUseCase({required this.authRepository});

  Future<Either<Result<SignupEntity>, ApiError>>call(Map<String,dynamic> data) async {
    return await authRepository.signUp(data);
  }
}