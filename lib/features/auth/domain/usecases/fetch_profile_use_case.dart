import 'package:dartz/dartz.dart';
import 'package:kalyanboss/features/auth/data/repository/auth_repository_impl.dart';
import 'package:kalyanboss/features/auth/domain/entities/user_entity.dart';
import 'package:kalyanboss/utils/api/api_error.dart';
import 'package:kalyanboss/utils/api/api_result.dart';

class FetchProfileUseCase {
  final AuthRepositoryImpl authRepository;

  FetchProfileUseCase({required this.authRepository});

  Future<Either<Result<UserEntity>, ApiError>> call(Map<String, dynamic> data,) async {
    return await authRepository.fetchProfile(data);
  }
}