part of 'auth_bloc.dart';

abstract class AuthEvent {}

class LoginEvent extends AuthEvent {
  final String mobile;
  final String password;

  LoginEvent({required this.mobile, required this.password});
}

class RegisterEvent extends AuthEvent {
  final String mobile;
  final String password;
  final String name;

  RegisterEvent({required this.name, required this.mobile, required this.password});
}

class SendOtpEvent extends AuthEvent {
  final String mobile;

  SendOtpEvent({required this.mobile});
}
class VerifyOtpEvent extends AuthEvent {
  final String mobile;
  final String otp;

  VerifyOtpEvent({required this.mobile, required this.otp});
}
class VerifyEvent extends AuthEvent {
  final String mobile;
  final String otp;

  VerifyEvent({required this.mobile, required this.otp});
}
class UpdateUserEvent extends AuthEvent {
  final String? fcm;
  final String? fullName;

  UpdateUserEvent({required this.fcm, required this.fullName});
}
class FetchProfileEvent extends AuthEvent {}
class FetchSettingEvent extends AuthEvent {}
class LogoutEvent extends AuthEvent {}

class ResetLoginStateEvent extends AuthEvent {}

class CheckAuthStatusEvent extends AuthEvent {}