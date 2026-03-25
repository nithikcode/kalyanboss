import 'package:dartz/dartz.dart';
import 'package:kalyanboss/features/game/data/datasource/game_remote_data_source.dart';
import 'package:kalyanboss/features/game/data/model/market_model.dart';
import 'package:kalyanboss/features/game/domain/entity/game_mode_entity.dart';
import 'package:kalyanboss/features/game/domain/entity/market_entity.dart' show MarketEntity, MarketResponseMapping, MarketResponseEntity;
import 'package:kalyanboss/features/game/domain/entity/result_entity.dart';
import 'package:kalyanboss/features/game/domain/repository/game_screen_repository.dart';
import 'package:kalyanboss/utils/api/api_error.dart';
import 'package:kalyanboss/utils/api/api_result.dart';

class GameScreenRepositoryImpl extends GameScreenRepository {
  final GameRemoteDataSource gameRemoteDataSource;
  GameScreenRepositoryImpl({ required this.gameRemoteDataSource});

  @override
  Future<Either<Result<MarketResponseEntity>, ApiError>> fetchAllMarket(Map<String, dynamic> data) async {
    final res = await gameRemoteDataSource.fetchAllMarket(data);
    return res.fold(
          (success) {
        if (success.isSuccess && success.data != null) {
          final result = success.data?.toEntity();
          return Left(Result.success(result));
        } else {
          return Right(
            ApiError(message: success.data?.message ?? "Fetch Markets Request failed"),
          );
        }
      },
          (error) => Right(ApiError(message: error.message)),
    );
  }

  @override
  Future<Either<Result<GameModeResponseEntity>, ApiError>> fetchGameModes(Map<String, dynamic> data) async {
    final res = await gameRemoteDataSource.fetchGameModes(data);
    return res.fold(
          (success) {
        if (success.isSuccess && success.data != null) {
          final result = success.data?.toEntity();
          return Left(Result.success(result));
        } else {
          return Right(
            ApiError(message: success.data?.message ?? "Fetch Game Modes Request failed"),
          );
        }
      },
          (error) => Right(ApiError(message: error.message)),
    );
  }

  @override
  Future<Either<Result<MarketResponse>, ApiError>> fetchMarketResult(Map<String, dynamic> data) async {
    final res = await gameRemoteDataSource.fetchMarketResult(data);
    return res.fold(
          (success) {
        if (success.isSuccess && success.data != null) {
          final result = success.data?.toEntity();
          return Left(Result.success(result));
        } else {
          return Right(
            ApiError(message: success.data?.status ?? "Fetch Game Modes Request failed"),
          );
        }
      },
          (error) => Right(ApiError(message: error.message)),
    );
  }


}