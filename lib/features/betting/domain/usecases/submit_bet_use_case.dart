import 'package:dartz/dartz.dart';
import 'package:kalyanboss/features/betting/data/repositoryimpl/betting_repository_impl.dart';
import 'package:kalyanboss/utils/api/api_error.dart';
import 'package:kalyanboss/utils/api/api_result.dart';

class SubmitBetUseCase {
  final BettingRepositoryImpl bettingRepository;

  SubmitBetUseCase({required this.bettingRepository});

  Future<Either<Result<String>, ApiError>> call(List<Map<String, dynamic>> data,) async {
    return await bettingRepository.createBet(data);
  }
}