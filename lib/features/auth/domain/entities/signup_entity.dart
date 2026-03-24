
import 'package:equatable/equatable.dart';
class SignupEntity extends Equatable {
  final String? message;
  final SignupDataEntity? data;

  const SignupEntity({
    this.message,
    this.data,
  });

  @override
  List<Object?> get props => [message, data];
}

class SignupDataEntity extends Equatable {
  final String? id;
  final String? mobile;

  const SignupDataEntity({
    this.id,
    this.mobile,
  });

  @override
  List<Object?> get props => [id, mobile];
}

