
import '../../../../utils/helpers/customJsonParser.dart';

class UserModel {
  final int id;
  final String? name;
  final String? email;
  final String? phone;
  final String? role;
  // final List<AddressModel>? addresses;
  final bool isVerified;
  final String refreshToken;
  final String accessToken;


  UserModel({required this.id, required this.name, required this.email, required this.role, required this.phone,  required this.isVerified, required this.refreshToken, required this.accessToken});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        id: json.parse<int>('id') ?? 0,
        name: json.parse<String>('name'),
        email: json.parse<String>('email'),
        role: json.parse<String>('role'),
        phone: json.parse<String>('phone'),
        // addresses: json.parseListOf('addresses', (i) => AddressModel.fromJson(i)) ?? [],
        isVerified: json.parse<bool>('isVerified') ?? false,
        refreshToken: json.parse<String>('refreshToken') ?? '',
        accessToken: json.parse<String>('accessToken') ?? ''
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'isVerified': isVerified,
      'refreshToken': refreshToken,
      'accessToken': accessToken,
    };
  }
}

// class AddressModel {
//   final int id;
//   final int userId;
//   final String fullName;
//   final String phone;
//   final String line1;
//   final String line2;
//   final String city;
//   final String state;
//   final String postal;
//   final String country;
//
//   AddressModel({required this.id, required this.userId, required this.fullName, required this.phone, required this.line1, required this.line2, required this.city, required this.state, required this.postal, required this.country});
//
//   factory AddressModel.fromJson(Map<String, dynamic> json) {
//     return AddressModel(
//       id: json.parse<int>('id') ?? 0,
//       userId: json.parse<int>('userId') ?? 0,
//         fullName: json.parse<String>('fullName') ?? '',
//         phone: json.parse<String>('phone') ?? '',
//         line1: json.parse<String>('line1') ?? '',
//         line2: json.parse<String>('line2') ?? '',
//         city: json.parse<String>('city') ?? '',
//         state: json.parse<String>('state') ?? '',
//         postal: json.parse<String>('postal') ?? '',
//         country: json.parse<String>('country') ?? ''
//     );
//   }
// }


