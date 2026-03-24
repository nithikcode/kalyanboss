import 'package:dartz/dartz.dart';
import 'package:kalyanboss/features/auth/data/model/user_model.dart';
import 'package:kalyanboss/features/auth/domain/entities/signup_entity.dart';
import 'package:kalyanboss/features/auth/domain/entities/user_entity.dart';
import 'package:kalyanboss/features/auth/domain/entities/verify_otp_entity.dart';
import 'package:kalyanboss/features/auth/domain/repository/auth_repository.dart';
import 'package:kalyanboss/utils/api/api_error.dart';
import 'package:kalyanboss/utils/api/api_result.dart';
import 'package:kalyanboss/utils/helpers/helpers.dart';

import '../datasource/auth_remote_data_source.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Result<String>, ApiError>> sendOtp(Map<String, dynamic> data) async {
    final res = await _remoteDataSource.sendOtp(data);
    return res.fold(
          (success) {
        if (success.isSuccess && success.data != null) {
          final result = success.data!;
          return Left(Result.success(result));
        } else {
          return Right(
            ApiError(message: success.data ?? "Signup Request failed"),
          );
        }
      },
          (error) => Right(ApiError(message: error.message)),
    );
  }

  @override
  Future<Either<Result<SignupEntity>, ApiError>> signUp(Map<String, dynamic> data) async {
    final res = await _remoteDataSource.register(data);
    return res.fold(
          (success) {
        if (success.isSuccess && success.data != null) {
          final result = success.data!.toEntity();
          return Left(Result.success(result));
        } else {
          return Right(
            ApiError(message: success.data?.message ?? "Signup Request failed"),
          );
        }
      },
          (error) => Right(ApiError(message: error.message)),
    );
  }

  @override
  Future<Either<Result<VerifyOtpEntity>, ApiError>> verify(Map<String, dynamic> data) async {
    final res = await _remoteDataSource.verify(data);
    return res.fold(
          (success) {
        if (success.isSuccess) {
          final result = success.data!.toEntity();
          createLog(success.data);
          return Left(Result.success(result));
        } else {
          return Right(ApiError(message: "Verify Request failed"));
        }
      },
          (error) {
        return Right(ApiError(message: error.message));
      },
    );
  }

  @override
  Future<Either<Result<VerifyOtpEntity>, ApiError>> login(Map<String, dynamic> data) async {
    final res = await _remoteDataSource.login(data);
    return res.fold(
          (success) {
        if (success.isSuccess) {
          final result = success.data?.toEntity();
          return Left(Result.success(result));
        } else {
          return Right(ApiError(message: "Send Otp Request failed"));
        }
      },
          (error) {
        return Right(ApiError(message: error.message));
      },
    );
  }

  @override
  Future<Either<Result<UserEntity>, ApiError>> fetchProfile(Map<String, dynamic> data) async {
    final res = await _remoteDataSource.fetchProfile(data);
    return res.fold(
          (success) {
        if (success.isSuccess) {
          final result = success.data?.toEntity();
          return Left(Result.success(result));
        } else {
          return Right(ApiError(message: "fetchProfile Request failed"));
        }
      },
          (error) {
        return Right(ApiError(message: error.message));
      },
    );
  }
}