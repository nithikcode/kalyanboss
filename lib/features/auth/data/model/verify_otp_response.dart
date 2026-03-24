import 'package:kalyanboss/utils/helpers/customJsonParser.dart';

class VerifyOtpResponseModel {
  final String? status;
  final String? message;
  final TokenDataModel? tokenData;
  final String? cookie;
  final UserDataModel? data;

  VerifyOtpResponseModel({
    this.status,
    this.message,
    this.tokenData,
    this.cookie,
    this.data,
  });

  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponseModel(
      status: json.parse<String>('status'),
      message: json.parse<String>('message'),
      cookie: json.parse<String>('cookie'),
      // Using your parseNested method
      tokenData: json.parseNested<TokenDataModel>(
          'tokenData',
              (map) => TokenDataModel.fromJson(map)
      ),
      data: json.parseNested<UserDataModel>(
          'data',
              (map) => UserDataModel.fromJson(map)
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'tokenData': tokenData?.toJson(),
    'cookie': cookie,
    'data': data?.toJson(),
  };
}

class TokenDataModel {
  final String? expiresIn;
  final String? token;

  TokenDataModel({this.expiresIn, this.token});

  factory TokenDataModel.fromJson(Map<String, dynamic> json) {
    return TokenDataModel(
      expiresIn: json.parse<String>('expiresIn'),
      token: json.parse<String>('token'),
    );
  }

  Map<String, dynamic> toJson() => {
    'expiresIn': expiresIn,
    'token': token,
  };
}

class UserDataModel {
  final String? id;
  final String? mobile;
  final bool verified;

  UserDataModel({this.id, this.mobile, required this.verified});

  factory UserDataModel.fromJson(Map<String, dynamic> json) {
    return UserDataModel(
      id: json.parse<String>('id'),
      mobile: json.parse<String>('mobile'), verified: json.parse('verified') ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'mobile': mobile,
    'verified' : verified
  };
}