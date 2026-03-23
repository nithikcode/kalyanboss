import 'package:dartz/dartz.dart';


import '../../../../utils/api/api_error.dart';
import '../../../../utils/api/api_result.dart';
import '../../data/repository/auth_repository_impl.dart';
import '../entities/user_entity.dart';

class SendOtpUseCase {
  final AuthRepositoryImpl authRepository;

  SendOtpUseCase({required this.authRepository});

  Future<Either<Result<String>,ApiError>>call(Map<String,dynamic> data) async {
    return await authRepository.sendOtp(data);
  }
}