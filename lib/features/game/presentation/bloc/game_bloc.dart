import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalyanboss/features/game/domain/entity/bet_history_entity.dart';
import 'package:kalyanboss/features/game/domain/entity/game_mode_entity.dart';
import 'package:kalyanboss/features/game/domain/entity/market_entity.dart';
import 'package:kalyanboss/features/game/domain/entity/result_entity.dart';
import 'package:kalyanboss/features/game/domain/entity/transaction_entity.dart';
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
  }) : super(GameState(
    marketResponseEntity: ApiState.initial(),
    gameModesEntity: ApiState.initial(),
    marketResponseResultEntity: ApiState.initial(),
    betResponseEntity: ApiState.initial(),
    transactionEntity: ApiState.initial(),
    galiDesawarMarketResponseEntity: ApiState.initial(),
    galiDesawarBetHistory: ApiState.initial(),
  )) {
    on<FetchAllMarkets>(_fetchAllMarkets);
    on<FetchGaliDesawarMarkets>(_fetchGaliDesawarMarkets);
    on<FetchGameModes>(_fetchAllGameModes);
    on<FetchMarketResult>(_fetchAllMarketResult);
    on<FetchBetHistory>(_fetchBetHistory);
    on<FetchGaliDesawarBetHistory>(_fetchGaliDesawarBetHistory);
    on<FetchTransactionHistory>(_fetchTransactionHistory);

    // Handle Date Selection Event
    on<SelectHistoryDate>((event, emit) {
      if (event.isFromDate) {
        emit(state.copyWith(fromDate: event.date));
      } else {
        emit(state.copyWith(toDate: event.date));
      }
    });
  }

  FutureOr<void> _fetchAllMarkets(FetchAllMarkets event, Emitter<GameState> emit) async {
    emit(state.copyWith(marketResponseEntity: ApiState.loading()));
    final result = await gameScreenUseCases.fetchAllMarketUseCase.call({'tag': 'main'});

    result.fold(
          (successResult) {
        if (successResult.data != null) {
          emit(state.copyWith(marketResponseEntity: ApiState.success(successResult.data!)));
        } else {
          emit(state.copyWith(marketResponseEntity: ApiState.error("No data found")));
        }
      },
          (apiError) => emit(state.copyWith(marketResponseEntity: ApiState.error(apiError.message))),
    );
  }

  Future<void> _fetchGaliDesawarMarkets(FetchGaliDesawarMarkets event, Emitter<GameState> emit) async {
    emit(state.copyWith(galiDesawarMarketResponseEntity: ApiState.loading()));
    final result = await gameScreenUseCases.fetchAllMarketUseCase.call({'tag': 'galidisawar'});

    result.fold(
          (successResult) {
        if (successResult.data != null) {
          emit(state.copyWith(galiDesawarMarketResponseEntity: ApiState.success(successResult.data!)));
        } else {
          emit(state.copyWith(galiDesawarMarketResponseEntity: ApiState.error("No data found")));
        }
      },
          (apiError) => emit(state.copyWith(galiDesawarMarketResponseEntity: ApiState.error(apiError.message))),
    );
  }

  FutureOr<void> _fetchAllGameModes(FetchGameModes event, Emitter<GameState> emit) async {
    emit(state.copyWith(gameModesEntity: ApiState.loading()));
    final result = await gameScreenUseCases.fetchGameModesUseCase.call({});

    result.fold(
          (successResult) {
        if (successResult.data != null) {
          emit(state.copyWith(gameModesEntity: ApiState.success(successResult.data!)));
        } else {
          emit(state.copyWith(gameModesEntity: ApiState.error("No Game Modes found")));
        }
      },
          (apiError) => emit(state.copyWith(gameModesEntity: ApiState.error(apiError.message))),
    );
  }

  Future<void> _fetchAllMarketResult(FetchMarketResult event, Emitter<GameState> emit) async {
    emit(state.copyWith(marketResponseResultEntity: ApiState.loading()));
    final data = {'market_id': event.marketId, 'tag': 'main'};
    final result = await gameScreenUseCases.fetchMarketResultUseCase.call(data);

    result.fold(
          (successResult) {
        if (successResult.data != null) {
          emit(state.copyWith(marketResponseResultEntity: ApiState.success(successResult.data!)));
        } else {
          emit(state.copyWith(marketResponseResultEntity: ApiState.error("No Result found")));
        }
      },
          (apiError) => emit(state.copyWith(marketResponseResultEntity: ApiState.error(apiError.message))),
    );
  }

  Future<void> _fetchBetHistory(FetchBetHistory event, Emitter<GameState> emit) async {
    emit(state.copyWith(betResponseEntity: ApiState.loading()));
    final data = {'user_id': sessionManager.getUserId};
    final result = await gameScreenUseCases.fetchBetHistoryUseCase.call(data);

    result.fold(
          (successResult) {
        if (successResult.data != null) {
          emit(state.copyWith(betResponseEntity: ApiState.success(successResult.data!)));
        } else {
          emit(state.copyWith(betResponseEntity: ApiState.error("No Result found")));
        }
      },
          (apiError) => emit(state.copyWith(betResponseEntity: ApiState.error(apiError.message))),
    );
  }

  Future<void> _fetchTransactionHistory(FetchTransactionHistory event, Emitter<GameState> emit) async {
    emit(state.copyWith(transactionEntity: ApiState.loading()));
    final data = {'user_id': sessionManager.getUserId};
    final result = await gameScreenUseCases.fetchTransactionUseCase.call(data);

    result.fold(
          (successResult) {
        if (successResult.data != null) {
          emit(state.copyWith(transactionEntity: ApiState.success(successResult.data!)));
        } else {
          emit(state.copyWith(transactionEntity: ApiState.error("No Result found")));
        }
      },
          (apiError) => emit(state.copyWith(transactionEntity: ApiState.error(apiError.message))),
    );
  }

  Future<void> _fetchGaliDesawarBetHistory(FetchGaliDesawarBetHistory event, Emitter<GameState> emit) async {
    emit(state.copyWith(galiDesawarBetHistory: ApiState.loading()));

    final data = <String, dynamic>{
      'user_id': sessionManager.getUserId,
      'tag': 'galidisawar'
    };

    // Safely append date parameters if the user has selected them
    if (state.fromDate != null) {
      final f = state.fromDate!;
      data['from_date'] = "${f.year}-${f.month.toString().padLeft(2, '0')}-${f.day.toString().padLeft(2, '0')}T00:00:00.000Z";
    }
    if (state.toDate != null) {
      final t = state.toDate!;
      data['to_date'] = "${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}T23:59:59.999Z";
    }

    final result = await gameScreenUseCases.fetchBetHistoryUseCase.call(data);

    result.fold(
          (successResult) {
        if (successResult.data != null) {
          emit(state.copyWith(galiDesawarBetHistory: ApiState.success(successResult.data!)));
        } else {
          emit(state.copyWith(galiDesawarBetHistory: ApiState.error("No Result found")));
        }
      },
          (apiError) => emit(state.copyWith(galiDesawarBetHistory: ApiState.error(apiError.message))),
    );
  }
}