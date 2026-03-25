import 'package:dartz/dartz.dart';
import 'package:kalyanboss/features/auth/data/repository/auth_repository_impl.dart';
import 'package:kalyanboss/features/auth/domain/entities/setting_entity.dart';
import 'package:kalyanboss/utils/api/api_error.dart';
import 'package:kalyanboss/utils/api/api_result.dart';

class FetchSettingsUseCase {
  final AuthRepositoryImpl authRepository;

  FetchSettingsUseCase({required this.authRepository});

  Future<Either<Result<SettingEntity>, ApiError>> call(Map<String, dynamic> data,) async {
    return await authRepository.fetchSettings(data);
  }
}