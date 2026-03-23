import 'dart:convert';
import '../../../../utils/helpers/customJsonParser.dart';

class SignupResponse {
  final String? message;
  final SignupData? data;

  SignupResponse({
    this.message,
    this.data,
  });

  factory SignupResponse.fromRawJson(String str) =>
      SignupResponse.fromJson(json.decode(str));

  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    return SignupResponse(
      message: json.parse<String>('message'),
      data: json.parseNested<SignupData>(
        'data',
            (map) => SignupData.fromJson(map),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data?.toJson(),
  };
}

class SignupData {
  final String? id;
  final String? mobile;

  SignupData({
    this.id,
    this.mobile,
  });

  factory SignupData.fromJson(Map<String, dynamic> json) {
    return SignupData(
      id: json.parse<String>('id'),
      mobile: json.parse<String>('mobile'),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "mobile": mobile,
  };
}