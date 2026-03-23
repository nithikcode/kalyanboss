


import 'package:kalyanboss/features/auth/domain/entities/signup_entity.dart';
import 'package:kalyanboss/features/auth/domain/entities/user_entity.dart';

import '../../../../utils/api/api_error.dart';
import '../../../../utils/api/api_result.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<Result<UserEntity>, ApiError>> login(Map<String, dynamic> data);
  Future<Either<Result<UserEntity>, ApiError>> verify(Map<String, dynamic> data);
  Future<Either<Result<SignupEntity>, ApiError>> signUp(Map<String, dynamic> data);
  Future<Either<Result<String>, ApiError>> sendOtp(Map<String, dynamic> data);

}