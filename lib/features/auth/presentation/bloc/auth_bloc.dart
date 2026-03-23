import 'dart:async';

import 'package:kalyanboss/features/auth/domain/entities/signup_entity.dart';
import 'package:kalyanboss/features/auth/domain/entities/user_entity.dart';
import 'package:kalyanboss/features/auth/domain/usecases/auth_use_cases.dart';
import 'package:kalyanboss/services/session_manager.dart';
import 'package:kalyanboss/utils/bloc/api_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthUseCases authUseCases;
  final SessionManager sessionManager;

  AuthBloc({required this.authUseCases, required this.sessionManager})
      : super(AuthState(userEntity: ApiState.initial(), signupEntity: ApiState.initial(), otpState: ApiState.initial())) {
    // on<LoginEvent>(_login);
    // on<VerifyEvent>(_verify);
    // on<ResetLoginStateEvent>(_resetLoginState);
    on<CheckAuthStatusEvent>(_checkAuthStatus);
    // on<LogoutEvent>(_logout);
    on<RegisterEvent>(_register);
    on<SendOtpEvent>(_sendOtp);

    // Check auth status on initialization
    add(CheckAuthStatusEvent());
  }

  Future<void> _checkAuthStatus(
      CheckAuthStatusEvent event,
      Emitter<AuthState> emit,
      ) async {
    final isAuthenticated = sessionManager.isAuthenticated();
    final user = sessionManager.getUserEntity;

    if (isAuthenticated && user != null) {
      emit(state.copyWith(
        isAuthenticated: true,
        userEntity: ApiState.success(user),
        loginRequested: false,
      ));
    } else {
      emit(state.copyWith(
        isAuthenticated: false,
        userEntity: ApiState.initial(),
        loginRequested: false,
      ));
    }
  }

  // Future<void> _login(LoginEvent event, Emitter<AuthState> emit) async {
  //   // 1. Basic Validation
  //   if (event.mobile.trim().isEmpty || event.password.trim().isEmpty) {
  //     return; // You could emit an error state here if preferred
  //   }
  //
  //   // 2. Set Loading State
  //   emit(state.copyWith(userEntity: ApiState.loading()));
  //
  //   final data = {
  //     'phone': event.mobile,
  //     'password': event.password, // Added password to payload
  //   };
  //
  //   final result = await authUseCases.loginUseCase.call(data);
  //
  //   await result.fold(
  //         (success) async {
  //       if (success.isSuccess && success.data != null) {
  //         final userData = success.data!;
  //
  //         // 3. Store session immediately since we are logging in directly
  //         await sessionManager.setSession(
  //           jwtAccessToken: userData.accessToken,
  //           jwtRefreshToken: userData.refreshToken,
  //           userId: userData.id.toString(),
  //           userEntity: userData,
  //         );
  //
  //         emit(state.copyWith(
  //           userEntity: ApiState.success(userData),
  //           isAuthenticated: true,
  //         ));
  //       } else {
  //         emit(state.copyWith(userEntity: ApiState.error("Invalid credentials")));
  //       }
  //     },
  //         (error) async {
  //       emit(state.copyWith(userEntity: ApiState.error(error.message)));
  //       await Fluttertoast.showToast(msg: error.message ?? 'Login failed');
  //     },
  //   );
  // }
  // Future<void> _verify(VerifyEvent event, Emitter<AuthState> emit) async {
  //   final data = {
  //     'phone': event.mobile,
  //     'otp': event.otp,
  //   };
  //
  //   final result = await authUseCases.verifyUseCase.call(data);
  //
  //   await result.fold(
  //         (success) async {
  //       if (success.isSuccess) {
  //         final userData = success.data;
  //
  //         // Store session with user entity
  //         await sessionManager.setSession(
  //           jwtAccessToken: userData?.accessToken,
  //           jwtRefreshToken: userData?.refreshToken,
  //           userId: userData?.id.toString(),
  //           userEntity: userData, // Store the entire user entity
  //         );
  //
  //         await Fluttertoast.showToast(
  //           webPosition: "top",
  //           msg: 'Logged in successfully',
  //           backgroundColor: Colors.green,
  //         );
  //
  //         emit(state.copyWith(
  //           loginRequested: false,
  //           userEntity: ApiState.success(userData!),
  //           isAuthenticated: true,
  //         ));
  //       } else {
  //         emit(state.copyWith(
  //           loginRequested: true,
  //           userEntity: ApiState.error("Verification failed"),
  //         ));
  //         await Fluttertoast.showToast(
  //           webPosition: "top",
  //           msg: 'Verification failed',
  //           backgroundColor: Colors.red,
  //         );
  //       }
  //     },
  //         (error) async {
  //       emit(state.copyWith(
  //         loginRequested: true,
  //         userEntity: ApiState.error(error.message),
  //       ));
  //       await Fluttertoast.showToast(
  //         msg: error.message ?? 'Invalid OTP',
  //         backgroundColor: Colors.red,
  //       );
  //     },
  //   );
  // }
  //
  // Future<void> _logout(LogoutEvent event, Emitter<AuthState> emit) async {
  //   await sessionManager.clearSession();
  //   emit(state.copyWith(
  //     loginRequested: false,
  //     userEntity: ApiState.initial(),
  //     isAuthenticated: false,
  //   ));
  //
  //   await Fluttertoast.showToast(
  //     webPosition: "top",
  //     msg: 'Logged out successfully',
  //     backgroundColor: Colors.green,
  //   );
  // }
  //
  // Future<void> _resetLoginState(ResetLoginStateEvent event, Emitter<AuthState> emit,) async {
  //   await sessionManager.clearSession();
  //   emit(state.copyWith(
  //     loginRequested: false,
  //     userEntity: ApiState.initial(),
  //     isAuthenticated: false,
  //   ));
  // }

  Future<void> _register(RegisterEvent event, Emitter<AuthState> emit) async {
    // 1. Basic Validation
    if (event.mobile.trim().isEmpty || event.password.trim().isEmpty) {
      emit(state.copyWith(signupEntity: ApiState.error("Please fill all fields")));
      return;
    }

    // 2. Set Loading State
    emit(state.copyWith(signupEntity: ApiState.loading()));

    final data = {
      'mobile': event.mobile,
      'password': event.password,
      'full_name': event.name
    };

    final result = await authUseCases.signUpUseCase.call(data);

    // 3. Handle Result (Left is Success, Right is Failure)
    await result.fold(
          (successResponse) async {
        // --- Handle SUCCESS (Left) ---
        if (successResponse.data != null) {
          // Map the Model to Entity using your extension
          final data = successResponse.data;

          emit(state.copyWith(
            signupEntity: ApiState.success(data!),
            isAuthenticated: true,
          ));

          // Display the specific message from the server (e.g., "Account created!")
          await Fluttertoast.showToast(
            msg: data.message,
            backgroundColor: Colors.green,
            gravity: ToastGravity.BOTTOM,
          );
        } else {
          // Fallback if data is null despite 200 OK
          const fallbackMsg = "Registration successful!";
          emit(state.copyWith(signupEntity: ApiState.error(fallbackMsg)));
          await Fluttertoast.showToast(msg: fallbackMsg);
        }
      },
          (failure) async {
        final errorMsg = failure.message ?? 'Signup failed';

        emit(state.copyWith(signupEntity: ApiState.error(errorMsg)));

        // Display server error message (e.g., "Mobile already exists")
        await Fluttertoast.showToast(
          msg: errorMsg,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      },
    );
  }

  FutureOr<void> _sendOtp(SendOtpEvent event, Emitter<AuthState> emit) async {
    // 1. Basic Validation
    if (event.mobile.trim().isEmpty || event.mobile.length < 10) {
      emit(state.copyWith(otpState: ApiState.error("Enter a valid mobile number")));
      return;
    }

    // 2. Set Loading State
    emit(state.copyWith(otpState: ApiState.loading()));

    final data = {
      'phone': event.mobile,
      // Add any other params your backend requires for OTP (e.g., 'type': 'register')
    };

    final result = await authUseCases.sendOtpUseCase.call(data);

    // 3. Handle Result (Left: Success, Right: Failure)
    await result.fold(
          (successResponse) async {
        // --- Handle SUCCESS (Left) ---
        // Map response to entity to get the server message
        final entity = successResponse.data;

        emit(state.copyWith(
          otpState: ApiState.success(entity!),
        ));

        // Show server's "OTP sent successfully" message
        await Fluttertoast.showToast(
          msg: entity,
          backgroundColor: Colors.green,
          gravity: ToastGravity.TOP,
        );
      },
          (failure) async {
        // --- Handle FAILURE (Right) ---
        final errorMsg = failure.message ?? 'Failed to send OTP';

        emit(state.copyWith(otpState: ApiState.error(errorMsg)));

        await Fluttertoast.showToast(
          msg: errorMsg,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      },
    );
  }
}