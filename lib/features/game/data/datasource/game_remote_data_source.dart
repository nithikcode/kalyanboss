import 'package:dartz/dartz.dart';
import 'package:kalyanboss/features/base/data/datasource/base_remote_data_source.dart';
import 'package:kalyanboss/features/game/data/model/bet_history_model.dart';
import 'package:kalyanboss/features/game/data/model/game_mode_model.dart';
import 'package:kalyanboss/features/game/data/model/market_model.dart';
import 'package:kalyanboss/features/game/data/model/result_model.dart';
import 'package:kalyanboss/features/game/data/model/transaction_model.dart';
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
      apiCall: () => _api.getApi('/app/market/all', queryParameters: data),
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

  /// fetch - betHistory
  Future<Either<Result<BetResponseModel>, ApiError>> betHistory(
      Map<String, dynamic> data,
      ) async {
    return execute<BetResponseModel>(
      apiCall: () => _api.getApi('/app/bet/get',queryParameters: data),
      onSuccess: (response) {
        // Parse user from response
        final data = BetResponseModel.fromJson(response);
        return data;
      },
      operationName: 'betHistory',
    );
  }

  /// fetch - transactionHistory
  Future<Either<Result<TransactionModel>, ApiError>> transactionHistory(
      Map<String, dynamic> data,
      ) async {
    return execute<TransactionModel>(
      apiCall: () => _api.getApi('/app/transaction/get',queryParameters: data),
      onSuccess: (response) {
        // Parse user from response
        final data = TransactionModel.fromJson(response);
        return data;
      },
      operationName: 'transactionHistory',
    );
  }
}