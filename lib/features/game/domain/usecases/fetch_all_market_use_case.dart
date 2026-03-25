import 'package:dartz/dartz.dart';
import 'package:kalyanboss/features/game/data/repository/game_screen_repository_impl.dart';
import 'package:kalyanboss/features/game/domain/entity/market_entity.dart';
import 'package:kalyanboss/utils/api/api_error.dart';
import 'package:kalyanboss/utils/api/api_result.dart';

class FetchAllMarketUseCase {
  final GameScreenRepositoryImpl gameScreenRepository;

  FetchAllMarketUseCase({required this.gameScreenRepository});

  Future<Either<Result<MarketResponseEntity>,ApiError>>call(Map<String,dynamic> data)async {
    return await gameScreenRepository.fetchAllMarket(data);
  }
}