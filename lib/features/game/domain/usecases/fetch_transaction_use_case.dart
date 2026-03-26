import 'package:dartz/dartz.dart';
import 'package:kalyanboss/features/game/data/repository/game_screen_repository_impl.dart';
import 'package:kalyanboss/features/game/domain/entity/transaction_entity.dart';
import 'package:kalyanboss/utils/api/api_error.dart';
import 'package:kalyanboss/utils/api/api_result.dart';

class FetchTransactionUseCase {
  final GameScreenRepositoryImpl gameScreenRepository;

  FetchTransactionUseCase({required this.gameScreenRepository});

  Future<Either<Result<TransactionEntity>, ApiError>> call(Map<String, dynamic> data,) async {
    return await gameScreenRepository.transactionHistory(data);
  }
}