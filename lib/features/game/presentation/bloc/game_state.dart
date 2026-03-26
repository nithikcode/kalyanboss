part of 'game_bloc.dart';


class GameState {
  ApiState<MarketResponseEntity>? marketResponseEntity;
  ApiState<MarketResponseEntity>? galiDesawarMarketResponseEntity;
  ApiState<GameModeResponseEntity>? gameModesEntity;
  ApiState<MarketResponse>? marketResponseResultEntity;
  ApiState<BetResponseEntity>? betResponseEntity; // bet history
  ApiState<BetResponseEntity>? galiDesawarBetHistory;
  ApiState<TransactionEntity>? transactionEntity;

  // New properties for UI Date Filtering
  DateTime? fromDate;
  DateTime? toDate;

  GameState({
    required this.marketResponseEntity,
    required this.galiDesawarBetHistory,
    required this.galiDesawarMarketResponseEntity,
    required this.transactionEntity,
    required this.gameModesEntity,
    required this.marketResponseResultEntity,
    required this.betResponseEntity,
    this.fromDate,
    this.toDate,
  });

  GameState copyWith({
    ApiState<MarketResponseEntity>? marketResponseEntity,
    ApiState<MarketResponseEntity>? galiDesawarMarketResponseEntity,
    ApiState<GameModeResponseEntity>? gameModesEntity,
    ApiState<MarketResponse>? marketResponseResultEntity,
    ApiState<BetResponseEntity>? betResponseEntity,
    ApiState<BetResponseEntity>? galiDesawarBetHistory,
    ApiState<TransactionEntity>? transactionEntity,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return GameState(
      marketResponseEntity: marketResponseEntity ?? this.marketResponseEntity,
      galiDesawarMarketResponseEntity: galiDesawarMarketResponseEntity ?? this.galiDesawarMarketResponseEntity,
      gameModesEntity: gameModesEntity ?? this.gameModesEntity,
      marketResponseResultEntity: marketResponseResultEntity ?? this.marketResponseResultEntity,
      betResponseEntity: betResponseEntity ?? this.betResponseEntity,
      galiDesawarBetHistory: galiDesawarBetHistory ?? this.galiDesawarBetHistory,
      transactionEntity: transactionEntity ?? this.transactionEntity,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
    );
  }
}