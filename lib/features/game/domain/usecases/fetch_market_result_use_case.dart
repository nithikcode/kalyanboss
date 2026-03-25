import 'package:dartz/dartz.dart';
import 'package:kalyanboss/features/game/data/repository/game_screen_repository_impl.dart';
import 'package:kalyanboss/features/game/domain/entity/result_entity.dart';
import 'package:kalyanboss/utils/api/api_error.dart';
import 'package:kalyanboss/utils/api/api_result.dart';

class FetchMarketResultUseCase {
  final GameScreenRepositoryImpl gameScreenRepository;

  FetchMarketResultUseCase({required this.gameScreenRepository});

  Future<Either<Result<MarketResponse>, ApiError>> call(Map<String, dynamic> data) async {
    return await gameScreenRepository.fetchMarketResult(data);
  }
}