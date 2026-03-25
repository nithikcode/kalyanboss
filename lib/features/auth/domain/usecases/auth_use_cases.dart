import 'package:kalyanboss/features/auth/domain/usecases/fetch_profile_use_case.dart';
import 'package:kalyanboss/features/auth/domain/usecases/fetch_settings_use_case.dart';
import 'package:kalyanboss/features/auth/domain/usecases/login_use_case.dart';
import 'package:kalyanboss/features/auth/domain/usecases/send_otp_use_case.dart';
import 'package:kalyanboss/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:kalyanboss/features/auth/domain/usecases/update_user_use_case.dart';
import 'package:kalyanboss/features/auth/domain/usecases/verify_use_case.dart';

class AuthUseCases {
  final LoginUseCase loginUseCase;
  final VerifyUseCase verifyUseCase;
  final SignUpUseCase signUpUseCase;
  final SendOtpUseCase sendOtpUseCase;
  final FetchProfileUseCase fetchProfileUseCase;
  final UpdateUserUseCase updateUserUseCase;
  final FetchSettingsUseCase fetchSettingsUseCase;


  AuthUseCases({required this.loginUseCase,required  this.verifyUseCase, required this.signUpUseCase, required this.sendOtpUseCase, required this.fetchProfileUseCase, required this.updateUserUseCase, required this.fetchSettingsUseCase});
}