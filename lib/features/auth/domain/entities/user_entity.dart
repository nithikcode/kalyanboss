


import '../../data/model/user_model.dart';

class UserEntity {
  final int id;
  final String? name;
  final String? email;
  final String? phone;
  final String? role;
  final bool isVerified;
  final String refreshToken;
  final String accessToken;

  UserEntity({required this.id, required this.name, required this.email, required this.phone, required this.role, required this.isVerified, required this.refreshToken, required this.accessToken});
}


extension UserModelx on UserModel {
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      phone: phone,
      role: role,
      isVerified: isVerified,
      refreshToken: refreshToken,
      accessToken: accessToken,
    );

}
}