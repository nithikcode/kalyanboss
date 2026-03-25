part of 'auth_bloc.dart';


class AuthState {
  final ApiState<UserEntity>? userEntity;
  final bool loginRequested;
  final bool isAuthenticated;
  final ApiState<SignupEntity> signupEntity;
  final ApiState<String> otpState;
  final ApiState<VerifyOtpEntity> verifyOtpState;
  final ApiState<bool>? updateUserState;
  final ApiState<SettingEntity>? fetchSettingEntity;

  AuthState({required this.userEntity, this.loginRequested = false, this.isAuthenticated = false, required this.signupEntity, required this.otpState, required this.verifyOtpState, required this.updateUserState, required this.fetchSettingEntity});

// Update your copyWith signature to include this:
  AuthState copyWith({
    ApiState<UserEntity>? userEntity,
    bool? loginRequested,
    bool? isAuthenticated,
    ApiState<SignupEntity>? signupEntity,
    ApiState<String>? otpState,
    ApiState<VerifyOtpEntity>? verifyOtpState,
    ApiState<bool>? updateUserState, // Add this
    ApiState<SettingEntity>? fetchSettingEntity
  }) {
    return AuthState(
      userEntity: userEntity ?? this.userEntity,
      loginRequested: loginRequested ?? this.loginRequested,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      signupEntity: signupEntity ?? this.signupEntity,
      otpState: otpState ?? this.otpState,
      verifyOtpState: verifyOtpState ?? this.verifyOtpState,
      updateUserState: updateUserState ?? this.updateUserState, // Now it maps correctly
      fetchSettingEntity: fetchSettingEntity ?? this.fetchSettingEntity, // Now it maps correctly
    );
  }
}