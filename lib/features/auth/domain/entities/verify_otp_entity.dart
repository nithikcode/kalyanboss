import 'package:equatable/equatable.dart';
import 'package:kalyanboss/features/auth/data/model/verify_otp_response.dart';

class VerifyOtpEntity extends Equatable {
  final String status;
  final String message;
  final String? token;
  final String? expiresIn;
  final String? cookie;
  final String id;
  final String mobile;
  final bool verified;

  const VerifyOtpEntity({
    required this.status,
    required this.message,
    this.token,
    this.expiresIn,
    this.cookie,
    required this.id,
    required this.mobile, required this.verified,
  });

  /// CopyWith method for state management updates
  VerifyOtpEntity copyWith({
    String? status,
    String? message,
    String? token,
    String? expiresIn,
    String? cookie,
    String? id,
    String? mobile,
  }) {
    return VerifyOtpEntity(
      status: status ?? this.status,
      message: message ?? this.message,
      token: token ?? this.token,
      expiresIn: expiresIn ?? this.expiresIn,
      cookie: cookie ?? this.cookie,
      id: id ?? this.id,
      mobile: mobile ?? this.mobile, verified: verified ?? this.verified,
    );
  }

  @override
  List<Object?> get props => [
    status,
    message,
    token,
    expiresIn,
    cookie,
    id,
    mobile,
    verified
  ];
}

extension VerifyOtpResponseMapper on VerifyOtpResponseModel {
  VerifyOtpEntity toEntity() {
    return VerifyOtpEntity(
      status: status ?? '',
      message: message ?? '',
      // Accessing nested TokenDataModel fields
      token: tokenData?.token,
      expiresIn: tokenData?.expiresIn,
      cookie: cookie,
      // Accessing nested UserDataModel fields
      id: data?.id ?? '',
      mobile: data?.mobile ?? '',
      verified: data?.verified ?? false
    );
  }
}