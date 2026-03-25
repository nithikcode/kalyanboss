import 'package:dartz/dartz.dart';
import 'package:kalyanboss/features/game/data/model/market_model.dart';
import 'package:kalyanboss/features/game/domain/entity/game_mode_entity.dart';
import 'package:kalyanboss/features/game/domain/entity/market_entity.dart';
import 'package:kalyanboss/features/game/domain/entity/result_entity.dart';
import 'package:kalyanboss/utils/api/api_error.dart';
import 'package:kalyanboss/utils/api/api_result.dart';

abstract class GameScreenRepository {

  /// fetchAllMarket -
  Future<Either<Result<MarketResponseEntity>, ApiError>> fetchAllMarket(Map<String, dynamic> data,);
  Future<Either<Result<GameModeResponseEntity>, ApiError>> fetchGameModes(Map<String, dynamic> data,);
  Future<Either<Result<MarketResponse>, ApiError>> fetchMarketResult(Map<String, dynamic> data,);

}