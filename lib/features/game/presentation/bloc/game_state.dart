part of 'game_bloc.dart';


class GameState {
  ApiState<MarketResponseEntity>? marketResponseEntity;
  ApiState<GameModeResponseEntity>? gameModesEntity;
  ApiState<MarketResponse>? marketResponseResultEntity;

  GameState({required this.marketResponseEntity, required this.gameModesEntity, required this.marketResponseResultEntity});

  // Update your copyWith signature to include this:
  GameState copyWith({
    ApiState<MarketResponseEntity>? marketResponseEntity,
  ApiState<GameModeResponseEntity>? gameModesEntity,
  ApiState<MarketResponse>? marketResponseResultEntity,
  }) {
    return GameState(
      marketResponseEntity : marketResponseEntity ?? this.marketResponseEntity,
      gameModesEntity: gameModesEntity ?? this.gameModesEntity,
      marketResponseResultEntity: marketResponseResultEntity ?? this.marketResponseResultEntity,
    );
  }
}