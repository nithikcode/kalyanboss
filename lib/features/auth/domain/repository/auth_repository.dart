


import 'package:kalyanboss/features/auth/domain/entities/setting_entity.dart';
import 'package:kalyanboss/features/auth/domain/entities/signup_entity.dart';
import 'package:kalyanboss/features/auth/domain/entities/user_entity.dart';
import 'package:kalyanboss/features/auth/domain/entities/verify_otp_entity.dart';

import '../../../../utils/api/api_error.dart';
import '../../../../utils/api/api_result.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<Result<VerifyOtpEntity>, ApiError>> login(Map<String, dynamic> data);
  Future<Either<Result<VerifyOtpEntity>, ApiError>> verify(Map<String, dynamic> data);
  Future<Either<Result<SignupEntity>, ApiError>> signUp(Map<String, dynamic> data);
  Future<Either<Result<String>, ApiError>> sendOtp(Map<String, dynamic> data);
  Future<Either<Result<UserEntity>, ApiError>> fetchProfile(Map<String, dynamic> data,);
  Future<Either<Result<String>, ApiError>> updateUser(Map<String, dynamic> data,);
  Future<Either<Result<SettingEntity>, ApiError>> fetchSettings(Map<String, dynamic> data,);
}