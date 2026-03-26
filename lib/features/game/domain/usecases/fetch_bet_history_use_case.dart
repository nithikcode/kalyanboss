import 'package:dartz/dartz.dart';
import 'package:kalyanboss/features/game/data/repository/game_screen_repository_impl.dart';
import 'package:kalyanboss/features/game/domain/entity/bet_history_entity.dart';
import 'package:kalyanboss/utils/api/api_error.dart';
import 'package:kalyanboss/utils/api/api_result.dart';

class FetchBetHistoryUseCase {
  final GameScreenRepositoryImpl gameScreenRepository;

  FetchBetHistoryUseCase({required this.gameScreenRepository});

  Future<Either<Result<BetResponseEntity>, ApiError>> call(Map<String, dynamic> data,) async {
    return await gameScreenRepository.betHistory(data);
  }
}