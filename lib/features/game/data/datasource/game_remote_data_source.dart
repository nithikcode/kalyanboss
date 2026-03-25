import 'package:dartz/dartz.dart';
import 'package:kalyanboss/features/base/data/datasource/base_remote_data_source.dart';
import 'package:kalyanboss/features/game/data/model/game_mode_model.dart';
import 'package:kalyanboss/features/game/data/model/market_model.dart';
import 'package:kalyanboss/features/game/data/model/result_model.dart';
import 'package:kalyanboss/features/game/domain/entity/result_entity.dart' as result;
import 'package:kalyanboss/utils/api/api_error.dart';
import 'package:kalyanboss/utils/api/api_result.dart';
import 'package:kalyanboss/utils/network/network_api_service.dart';

class GameRemoteDataSource extends BaseRemoteDataSource {
  final NetworkServicesApi _api;

  GameRemoteDataSource({NetworkServicesApi? api})
      : _api = api ?? NetworkServicesApi();

  /// fetchAllMarket -
  Future<Either<Result<MarketResponseModel>, ApiError>> fetchAllMarket(
      Map<String, dynamic> data,
      ) async {
    return execute<MarketResponseModel>(
      apiCall: () => _api.getApi('/app/market/all'),
      onSuccess: (response) {
        // Parse user from response
        final data = MarketResponseModel.fromJson(response);
        return data;
      },
      operationName: 'fetchAllMarket',
    );
  }

  /// fetchGameModes -
  Future<Either<Result<GameModeResponseModel>, ApiError>> fetchGameModes(
      Map<String, dynamic> data,
      ) async {
    return execute<GameModeResponseModel>(
      apiCall: () => _api.getApi('/app/game-mode/all'),
      onSuccess: (response) {
        // Parse user from response
        final data = GameModeResponseModel.fromJson(response);
        return data;
      },
      operationName: 'fetchGameModes',
    );
  }


  /// fetchResult -
  Future<Either<Result<MarketResponseResultModel>, ApiError>> fetchMarketResult(
      Map<String, dynamic> data,
      ) async {
    return execute<MarketResponseResultModel>(
      apiCall: () => _api.getApi('/public/result',queryParameters: data),
      onSuccess: (response) {
        // Parse user from response
        final data = MarketResponseResultModel.fromJson(response);
        return data;
      },
      operationName: 'fetchResult',
    );
  }
}