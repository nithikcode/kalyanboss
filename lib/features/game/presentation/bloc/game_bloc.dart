import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalyanboss/features/game/domain/entity/game_mode_entity.dart';
import 'package:kalyanboss/features/game/domain/entity/market_entity.dart';
import 'package:kalyanboss/features/game/domain/entity/result_entity.dart' as result;
import 'package:kalyanboss/features/game/domain/entity/result_entity.dart';
import 'package:kalyanboss/features/game/domain/usecases/game_screen_use_cases.dart';
import 'package:kalyanboss/services/session_manager.dart';
import 'package:kalyanboss/utils/bloc/api_state.dart';
part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final GameScreenUseCases gameScreenUseCases;
  final SessionManager sessionManager;

  GameBloc({
    required this.gameScreenUseCases,
    required this.sessionManager,
  }) : super(GameState(marketResponseEntity: ApiState.initial(), gameModesEntity: ApiState.initial(), marketResponseResultEntity: ApiState.initial())) {
    on<FetchAllMarkets>(_fetchAllMarkets);
    on<FetchGameModes>(_fetchAllGameModes);
    on<FetchMarketResult>(_fetchAllMarketResult);
  }

  FutureOr<void> _fetchAllMarkets(
      FetchAllMarkets event,
      Emitter<GameState> emit,
      ) async
  {
    // 1. Emit Loading State
    emit(state.copyWith(marketResponseEntity: ApiState.loading()));

    // 2. Execute Use Case
    // Passing empty map or event.params if your event carries data
    final result = await gameScreenUseCases.fetchAllMarketUseCase.call({});

    // 3. Handle Result
    result.fold(
          (successResult) {
        // successResult is Result<MarketResponseEntity>
        if (successResult.data != null) {
          emit(state.copyWith(
            marketResponseEntity: ApiState.success(successResult.data!),
          ));
        } else {
          emit(state.copyWith(
            marketResponseEntity: ApiState.error("No data found"),
          ));
        }
      },
          (apiError) {
        // apiError is ApiError
        emit(state.copyWith(
          marketResponseEntity: ApiState.error(apiError.message),
        ));
      },
    );
  }

  FutureOr<void> _fetchAllGameModes(
      FetchGameModes event,
      Emitter<GameState> emit
      ) async {
    // 1. Emit Loading State for Game Modes
    emit(state.copyWith(gameModesEntity: ApiState.loading()));

    // 2. Execute Use Case
    // Note: Adjust the parameter {} if your use case requires specific IDs
    final result = await gameScreenUseCases.fetchGameModesUseCase.call({});

    // 3. Handle Result
    result.fold(
          (successResult) {
        // successResult.data is GameModeResponseEntity
        if (successResult.data != null) {
          emit(state.copyWith(
            gameModesEntity: ApiState.success(successResult.data!),
          ));
        } else {
          emit(state.copyWith(
            gameModesEntity: ApiState.error("No Game Modes found"),
          ));
        }
      },
          (apiError) {
        emit(state.copyWith(
          gameModesEntity: ApiState.error(apiError.message),
        ));
      },
    );
  }

  Future<void> _fetchAllMarketResult(FetchMarketResult event, Emitter<GameState> emit) async {
    // 1. Emit Loading State for Game Modes
    emit(state.copyWith(marketResponseResultEntity: ApiState.loading()));

    // 2. Execute Use Case
    // Note: Adjust the parameter {} if your use case requires specific IDs
    final data = {
      'market_id' : event.marketId,
      'tag' : 'main'
    };
    final result = await gameScreenUseCases.fetchMarketResultUseCase.call(data);

    // 3. Handle Result
    result.fold(
          (successResult) {
        // successResult.data is GameModeResponseEntity
        if (successResult.data != null) {
          emit(state.copyWith(
            marketResponseResultEntity: ApiState.success(successResult.data!),
          ));
        } else {
          emit(state.copyWith(
            marketResponseResultEntity: ApiState.error("No Result found"),
          ));
        }
      },
          (apiError) {
        emit(state.copyWith(
          marketResponseResultEntity: ApiState.error(apiError.message),
        ));
      },
    );
  }
}