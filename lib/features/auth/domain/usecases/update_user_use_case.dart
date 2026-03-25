import 'package:dartz/dartz.dart';
import 'package:kalyanboss/features/auth/data/repository/auth_repository_impl.dart';
import 'package:kalyanboss/utils/api/api_error.dart';
import 'package:kalyanboss/utils/api/api_result.dart';

class UpdateUserUseCase {
  final AuthRepositoryImpl authRepository;

  UpdateUserUseCase({required this.authRepository});

  Future<Either<Result<String>, ApiError>> call(Map<String, dynamic> data,) {
    return authRepository.updateUser(data);
  }
}