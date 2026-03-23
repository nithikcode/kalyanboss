import 'package:kalyanboss/features/auth/domain/usecases/login_use_case.dart';
import 'package:kalyanboss/features/auth/domain/usecases/send_otp_use_case.dart';
import 'package:kalyanboss/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:kalyanboss/features/auth/domain/usecases/verify_use_case.dart';

class AuthUseCases {
  final LoginUseCase loginUseCase;
  final VerifyUseCase verifyUseCase;
  final SignUpUseCase signUpUseCase;
  final SendOtpUseCase sendOtpUseCase;


  AuthUseCases({required this.loginUseCase,required  this.verifyUseCase, required this.signUpUseCase, required this.sendOtpUseCase});
}