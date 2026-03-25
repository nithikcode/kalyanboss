
part of 'game_bloc.dart';
abstract class GameEvent {}

class FetchAllMarkets extends GameEvent {}
class FetchGameModes extends GameEvent {}
class FetchMarketResult extends GameEvent {
  final String marketId;

  FetchMarketResult({required this.marketId});
}