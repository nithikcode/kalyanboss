import '../../data/model/signup_response.dart';

class SignupEntity {
  final String id;
  final String? mobile;
  final String message;

  SignupEntity({
    required this.id,
    required this.message,
    this.mobile,
  });
}

extension SignupModelX on SignupResponse {
  SignupEntity toEntity() {
    return SignupEntity(
      id: data?.id ?? '',
      mobile: data?.mobile,
      message: message ?? 'Success',
    );
  }
}