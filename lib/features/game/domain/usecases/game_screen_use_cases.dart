import 'package:kalyanboss/features/game/domain/usecases/fetch_all_market_use_case.dart';
import 'package:kalyanboss/features/game/domain/usecases/fetch_bet_history_use_case.dart';
import 'package:kalyanboss/features/game/domain/usecases/fetch_game_modes_use_case.dart';
import 'package:kalyanboss/features/game/domain/usecases/fetch_market_result_use_case.dart';
import 'package:kalyanboss/features/game/domain/usecases/fetch_transaction_use_case.dart';

class GameScreenUseCases {
  final FetchAllMarketUseCase fetchAllMarketUseCase;
  final FetchGameModesUseCase fetchGameModesUseCase;
  final FetchMarketResultUseCase fetchMarketResultUseCase;
  final FetchBetHistoryUseCase fetchBetHistoryUseCase;
  final FetchTransactionUseCase fetchTransactionUseCase;

  GameScreenUseCases({required this.fetchAllMarketUseCase, required this.fetchGameModesUseCase, required this.fetchMarketResultUseCase, required this.fetchBetHistoryUseCase, required this.fetchTransactionUseCase});
}