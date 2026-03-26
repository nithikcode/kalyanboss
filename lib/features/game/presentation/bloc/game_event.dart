
part of 'game_bloc.dart';

abstract class GameEvent {}

class FetchAllMarkets extends GameEvent {}
class FetchGaliDesawarMarkets extends GameEvent {}
class FetchGameModes extends GameEvent {}

class FetchMarketResult extends GameEvent {
  final String marketId;
  FetchMarketResult({required this.marketId});
}

class FetchBetHistory extends GameEvent {}

class FetchGaliDesawarBetHistory extends GameEvent {
  final String? query;
  FetchGaliDesawarBetHistory({this.query});
}

class FetchTransactionHistory extends GameEvent {}

// --- NEW EVENTS FOR FILTERS ---
class SelectHistoryDate extends GameEvent {
  final DateTime date;
  final bool isFromDate;

  SelectHistoryDate({required this.date, required this.isFromDate});
}