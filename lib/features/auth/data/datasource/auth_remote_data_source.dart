
import 'package:dartz/dartz.dart';
import 'package:kalyanboss/features/auth/data/model/setting_model.dart';
import 'package:kalyanboss/features/auth/data/model/user_model.dart';
import 'package:kalyanboss/features/auth/data/model/verify_otp_response.dart';
import 'package:kalyanboss/utils/api/api_error.dart';
import 'package:kalyanboss/utils/api/api_result.dart';


import '../../../../utils/network/network_api_service.dart';
import '../../../base/data/datasource/base_remote_data_source.dart';
import '../model/signup_response.dart';

class AuthRemoteDataSource extends BaseRemoteDataSource {
  final NetworkServicesApi _api;

  AuthRemoteDataSource({NetworkServicesApi? api})
      : _api = api ?? NetworkServicesApi();

  /// Settings -
  Future<Either<Result<SettingModel>, ApiError>> fetchSettings(
      Map<String, dynamic> data,
      ) async {
    return execute<SettingModel>(
      apiCall: () => _api.getApi('/app/setting/get'),
      onSuccess: (response) {
        // Parse user from response
        final data = SettingModel.fromJson(response);
        return data;
      },
      operationName: 'Settings',
    );
  }

  /// Login -
  Future<Either<Result<VerifyOtpResponseModel>, ApiError>> login(
      Map<String, dynamic> data,
      ) async {
    return execute<VerifyOtpResponseModel>(
      apiCall: () => _api.postApi('/auth/loginpass', data),
      onSuccess: (response) {
        // Parse user from response
        final data = VerifyOtpResponseModel.fromJson(response);
        return data;
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
        final message = SignupResponse.fromJson(response);
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
  Future<Either<Result<VerifyOtpResponseModel>, ApiError>> verify(
      Map<String, dynamic> data,
      ) async {
    return execute<VerifyOtpResponseModel>(
      apiCall: () => _api.postApi('/auth/verify', data),
      onSuccess: (response) {
        // Parse user from response
        final data = VerifyOtpResponseModel.fromJson(response);
        return data;
      },
      operationName: 'VerifyOtp',
    );
  }


  /// Fetch Profile - Fetches user data
  Future<Either<Result<UserModel>, ApiError>> fetchProfile(Map<String, dynamic> data,) async {
    return execute<UserModel>(
      apiCall: () => _api.getApi('/app/users/get/${data['id']}'),
      onSuccess: (response) {
        // Parse user from response
        final data = UserModel.fromJson(response['data']);
        return data;
      },
      operationName: 'fetchProfile',
    );
  }
  Future<Either<Result<String>, ApiError>> updateUser(Map<String, dynamic> data,) async {
    return execute<String>(
      apiCall: () => _api.putApi('/app/users/update',data),
      onSuccess: (response) {
        // Parse user from response
        final data = response['message'];
        return data;
      },
      operationName: 'updateUser',
    );
  }


}