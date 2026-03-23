part of 'auth_bloc.dart';


class AuthState {
  final ApiState<UserEntity>? userEntity;
  final bool loginRequested;
  final bool isAuthenticated;
  final ApiState<SignupEntity> signupEntity;
  final ApiState<String> otpState;

  AuthState({required this.userEntity, this.loginRequested = false, this.isAuthenticated = false, required this.signupEntity, required this.otpState});

  AuthState copyWith({
    ApiState<UserEntity>? userEntity,
    bool? loginRequested = false,
    bool? isAuthenticated = false,
    ApiState<SignupEntity>? signupEntity,
    ApiState<String>? otpState
  }){
    return AuthState(
        userEntity: userEntity ?? this.userEntity,
        loginRequested: loginRequested ?? this.loginRequested,
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        signupEntity: signupEntity ?? this.signupEntity,
      otpState: otpState ?? this.otpState
    );
  }
}