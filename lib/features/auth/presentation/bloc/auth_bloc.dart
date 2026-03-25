import 'dart:async';

import 'package:kalyanboss/features/auth/domain/entities/setting_entity.dart';
import 'package:kalyanboss/features/auth/domain/entities/signup_entity.dart';
import 'package:kalyanboss/features/auth/domain/entities/user_entity.dart';
import 'package:kalyanboss/features/auth/domain/entities/verify_otp_entity.dart';
import 'package:kalyanboss/features/auth/domain/usecases/auth_use_cases.dart';
import 'package:kalyanboss/services/notification_manager.dart';
import 'package:kalyanboss/services/session_manager.dart';
import 'package:kalyanboss/utils/bloc/api_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kalyanboss/utils/di/service_locator.dart';
import 'package:kalyanboss/utils/helpers/helpers.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthUseCases authUseCases;
  final SessionManager sessionManager;

  AuthBloc({required this.authUseCases, required this.sessionManager})
      : super(AuthState(userEntity: ApiState.initial(), signupEntity: ApiState.initial(), otpState: ApiState.initial(), verifyOtpState: ApiState.initial(), updateUserState: ApiState.initial(), fetchSettingEntity: ApiState.initial())) {
    on<LoginEvent>(_login);
    on<VerifyOtpEvent>(_verify);
    on<FetchProfileEvent>(_fetchProfile);
    on<FetchSettingEvent>(_fetchSetting);
    on<CheckAuthStatusEvent>(_checkAuthStatus);
    on<LogoutEvent>(_logout);
    on<RegisterEvent>(_register);
    on<SendOtpEvent>(_sendOtp);
    on<UpdateUserEvent>(_updateUser);

    // Check auth status on initialization
    add(CheckAuthStatusEvent());
  }
  Future<void> _logout(LogoutEvent event, Emitter<AuthState> emit) async {
    // 1. Clear the physical storage
    await sessionManager.clearSession();

    // 2. Emit the "Unauthenticated" state
    emit(state.copyWith(
      isAuthenticated: false,
      userEntity: ApiState.initial(),
      verifyOtpState: ApiState.initial(),
      signupEntity: ApiState.initial(),
    ));

    // GoRouter's refreshListenable will now see this change and trigger the redirect!
  }
  Future<void> _checkAuthStatus(
      CheckAuthStatusEvent event,
      Emitter<AuthState> emit,
      ) async {
    final isAuthenticated = sessionManager.isAuthenticated();

    if (isAuthenticated) {
      // 1. Immediately acknowledge we are logged in
      emit(state.copyWith(isAuthenticated: true));

      // 2. Automatically trigger the profile fetch to get fresh data
      add(FetchProfileEvent());
      add(FetchSettingEvent());

      final token = await sl<NotificationService>().getDeviceToken();
      if (token != null) {
        add(UpdateUserEvent(fcm: token, fullName: null));
      }
    } else {
      emit(state.copyWith(
        isAuthenticated: false,
        userEntity: ApiState.initial(),
      ));
    }
  }



  Future<void> _register(RegisterEvent event, Emitter<AuthState> emit) async {
    if (event.mobile.trim().isEmpty || event.password.trim().isEmpty) {
      emit(state.copyWith(signupEntity: ApiState.error("Please fill all fields")));
      return;
    }

    emit(state.copyWith(signupEntity: ApiState.loading()));

    final data = {
      'mobile': event.mobile,
      'password': event.password,
      'full_name': event.name
    };

    final result = await authUseCases.signUpUseCase.call(data);

    await result.fold(
          (successResponse) async {
        if (successResponse.data != null) {
          final data = successResponse.data!;

          emit(state.copyWith(
            signupEntity: ApiState.success(data),
            // IMPORTANT: Keep isAuthenticated: false here.
            // Only set to true AFTER OTP is verified.
            isAuthenticated: false,
          ));

          await Fluttertoast.showToast(
            msg: data.message ?? "",
            backgroundColor: Colors.green,
          );

          // --- TRIGGER OTP AUTOMATICALLY ---
          // Use 'add' to fire the existing _sendOtp logic using the mobile from the event
          add(SendOtpEvent(mobile: event.mobile));

        } else {
          emit(state.copyWith(signupEntity: ApiState.error("Registration successful but no data received")));
        }
      },
          (failure) async {
        final errorMsg = failure.message ?? 'Signup failed';
        emit(state.copyWith(signupEntity: ApiState.error(errorMsg)));
        await Fluttertoast.showToast(msg: errorMsg, backgroundColor: Colors.red);
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
      'mobile': event.mobile,
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


  Future<void> _verify(VerifyOtpEvent event, Emitter<AuthState> emit) async {
    if (event.otp.length < 6) {
      emit(state.copyWith(verifyOtpState: ApiState.error("Enter a valid 6-digit OTP")));
      return;
    }

    emit(state.copyWith(verifyOtpState: ApiState.loading()));

    final data = {
      'mobile': event.mobile,
      'otp': event.otp,
    };

    final result = await authUseCases.verifyUseCase.call(data);

    await result.fold(
          (successResponse) async {
        final entity = successResponse.data;

        if (entity != null) {
          createLog("Userid ${entity.id}");
          // 1. Save Token and Session
          await sessionManager.setSession(jwtAccessToken: entity.token,userId: entity.id);

          // 2. Update Bloc State to Authenticated
          emit(state.copyWith(
            verifyOtpState: ApiState.success(entity),
            isAuthenticated: true,
          ));
          add(FetchProfileEvent());
          add(FetchSettingEvent());

          final fcmToken = await sl<NotificationService>().getDeviceToken();
          if (fcmToken != null) {
            add(UpdateUserEvent(fcm: fcmToken, fullName: null));
          }
          await Fluttertoast.showToast(
            msg: entity.message,
            backgroundColor: Colors.green,
          );
        }
      },
          (failure) async {
        final errorMsg = failure.message ?? 'Verification failed';
        emit(state.copyWith(verifyOtpState: ApiState.error(errorMsg)));
        await Fluttertoast.showToast(msg: errorMsg, backgroundColor: Colors.red);
      },
    );
  }

  Future<void> _login(LoginEvent event, Emitter<AuthState> emit) async {
    if (event.password.isEmpty && event.mobile.isEmpty) {
      emit(state.copyWith(verifyOtpState: ApiState.error("Mobile and Password are required")));
      return;
    }

    emit(state.copyWith(verifyOtpState: ApiState.loading()));

    final data = {
      'mobile': event.mobile,
      'password': event.password,
    };

    final result = await authUseCases.loginUseCase.call(data);

    await result.fold(
          (successResponse) async {
        final entity = successResponse.data;

        if (entity != null) {
          createLog("Userid ${entity.id}");

          // 1. Save Token and Session
          await sessionManager.setSession(jwtAccessToken: entity.token, userId: entity.id);

          // 2. Update Bloc State to Authenticated
          emit(state.copyWith(
            verifyOtpState: ApiState.success(entity),
            isAuthenticated: true,
          ));
          add(FetchProfileEvent());
          add(FetchSettingEvent());

          final fcmToken = await sl<NotificationService>().getDeviceToken();
          if (fcmToken != null) {
            add(UpdateUserEvent(fcm: fcmToken, fullName: null));
          }
          await Fluttertoast.showToast(
            msg: entity.message,
            backgroundColor: Colors.green,
          );
        }
      },
          (failure) async {
        final errorMsg = failure.message ?? 'Verification failed';
        emit(state.copyWith(verifyOtpState: ApiState.error(errorMsg)));
        await Fluttertoast.showToast(msg: errorMsg, backgroundColor: Colors.red);
      },
    );
  }

  Future<void> _fetchProfile(FetchProfileEvent event, Emitter<AuthState> emit) async {
    createLog("!!! FETCH PROFILE EVENT TRIGGERED !!!"); // <--- ADD THIS
    emit(state.copyWith(userEntity: ApiState.loading()));
  createLog("Userid is ${sessionManager.getUserId}");
    final data = {
      'id': sessionManager.getUserId,
    };

    final result = await authUseCases.fetchProfileUseCase.call(data);

    await result.fold(
          (successResponse) async {
        final entity = successResponse.data;

        if (entity != null) {
          createLog("UserModel ${entity}");

          // 1. Save Token and Session
          await sessionManager.setSession(jwtAccessToken: entity.token, userId: entity.id, userEntity: entity);


          // 2. Update Bloc State to Authenticated
          emit(state.copyWith(
            userEntity: ApiState.success(entity),
            isAuthenticated: true,
          ));

        }
      },
          (failure) async {
        final errorMsg = failure.message ?? 'Verification failed';
        emit(state.copyWith(userEntity: ApiState.error(errorMsg)));
        await Fluttertoast.showToast(msg: errorMsg, backgroundColor: Colors.red);
      },
    );
  }
  FutureOr<void> _updateUser(UpdateUserEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(updateUserState: ApiState.loading()));

    // 1. Build a dynamic map including only non-empty values
    final Map<String, dynamic> requestData = {
      // 'id': sessionManager.getUserId, // Usually required to identify the user
      if (event.fcm != null && event.fcm!.isNotEmpty) 'fcm': event.fcm,
      if (event.fullName != null && event.fullName!.isNotEmpty) 'full_name': event.fullName,
    };

    // 2. Safety Check: If only 'id' is present, no need to call the API
    if (requestData.isEmpty) {
      emit(state.copyWith(updateUserState: ApiState.initial()));
      return;
    }

    final result = await authUseCases.updateUserUseCase.call(requestData);

    await result.fold(
          (successResponse) async {
        emit(state.copyWith(updateUserState: ApiState.success(true)));

        // await Fluttertoast.showToast(
        //   msg: "Profile updated successfully",
        //   backgroundColor: Colors.green,
        // );
        createLog("Fcm token updated ${successResponse.data}");

      },
          (failure) async {
        final errorMsg = failure.message ?? 'Update failed';
        emit(state.copyWith(updateUserState: ApiState.error(errorMsg)));
        await Fluttertoast.showToast(msg: errorMsg, backgroundColor: Colors.red);
      },
    );
  }

  Future<void> _fetchSetting(FetchSettingEvent event, Emitter<AuthState> emit) async {
    createLog("!!! FETCH SETTING EVENT TRIGGERED !!!"); // <--- ADD THIS
    emit(state.copyWith(fetchSettingEntity: ApiState.loading()));

    final result = await authUseCases.fetchSettingsUseCase.call({});

    await result.fold(
          (successResponse) async {
        final entity = successResponse.data;

        if (entity != null) {
          createLog("Setting Model ${entity}");

          // 2. Update Bloc State to Authenticated
          emit(state.copyWith(
            fetchSettingEntity: ApiState.success(entity),
            isAuthenticated: true,
          ));

        }
      },
          (failure) async {
        final errorMsg = failure.message ?? 'Verification failed';
        emit(state.copyWith(fetchSettingEntity: ApiState.error(errorMsg)));
        await Fluttertoast.showToast(msg: errorMsg, backgroundColor: Colors.red);
      },
    );
  }
}