
import 'package:dartz/dartz.dart';

import '../../../../utils/api/api_error.dart';
import '../../../../utils/api/api_result.dart';
import '../../../../utils/network/network_api_service.dart';
import '../../../base/data/datasource/base_remote_data_source.dart';
import '../model/signup_response.dart';
import '../model/user_model.dart';

class AuthRemoteDataSource extends BaseRemoteDataSource {
  final NetworkServicesApi _api;

  AuthRemoteDataSource({NetworkServicesApi? api})
      : _api = api ?? NetworkServicesApi();

  /// Login -
  Future<Either<Result<UserModel>, ApiError>> login(
      Map<String, dynamic> data,
      ) async {
    return execute<UserModel>(
      apiCall: () => _api.postApi('/auth/login', data),
      onSuccess: (response) {
        // Response is already decoded by Dio
        final message = response['message'] ?? 'OTP sent successfully';
        return message;
      },
      operationName: 'Login',
    );
  }

  Future<Either<Result<SignupResponse>, ApiError>> register(
      Map<String, dynamic> data,
      ) async {
    return execute<SignupResponse>(
      apiCall: () => _api.postApi('/auth/signup', data),
      onSuccess: (response) {
        // Response is already decoded by Dio
        final message = response['message'] ?? 'Registration Successful';
        return message;
      },
      operationName: 'Signup',
    );
  }

  Future<Either<Result<String>, ApiError>> sendOtp(
      Map<String, dynamic> data,
      ) async {
    return execute<String>(
      apiCall: () => _api.postApi('/auth/send', data),
      onSuccess: (response) {
        // Response is already decoded by Dio
        final message = response['message'] ?? 'Otp Sent';
        return message;
      },
      operationName: 'Send Otp',
    );
  }

  /// Verify - Verifies OTP and returns user data
  Future<Either<Result<UserModel>, ApiError>> verify(
      Map<String, dynamic> data,
      ) async {
    return execute<UserModel>(
      apiCall: () => _api.postApi('/auth/verify', data),
      onSuccess: (response) {
        // Parse user from response
        final userData = response['data'];
        return UserModel.fromJson(userData);
      },
      operationName: 'Verify',
    );
  }
}