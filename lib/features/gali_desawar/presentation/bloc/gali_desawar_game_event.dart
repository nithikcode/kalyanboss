part of 'gali_desawar_game_bloc.dart';

abstract class GaliDesawarGameEvent {}

// ─────────────────────────────────────────────────────────────────────────────
// Init
// ─────────────────────────────────────────────────────────────────────────────

/// Fired when the market selected screen opens.
class InitGaliDesawarGameEvent extends GaliDesawarGameEvent {
  final MarketEntity market;
  final String tag;
  final String userId;

  InitGaliDesawarGameEvent({
    required this.market,
    required this.tag,
    required this.userId,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Mode switch
// ─────────────────────────────────────────────────────────────────────────────

class SwitchGaliModeEvent extends GaliDesawarGameEvent {
  final GaliDesawarMode mode;
  SwitchGaliModeEvent(this.mode);
}

// ─────────────────────────────────────────────────────────────────────────────
// Open Play events
// ─────────────────────────────────────────────────────────────────────────────

/// Recalculate open play bets from raw text input.
class RecalculateOpenPlayEvent extends GaliDesawarGameEvent {
  final String numbersText;   // pairs like "2345" → "23", "45"
  final String amountText;
  final String harupText;
  final String harupAmountText;

  RecalculateOpenPlayEvent({
    required this.numbersText,
    required this.amountText,
    required this.harupText,
    required this.harupAmountText,
  });
}

class ToggleOpenPlayPaltiEvent extends GaliDesawarGameEvent {}
class ToggleOpenPlayHarupAndarEvent extends GaliDesawarGameEvent {}
class ToggleOpenPlayHarupBaharEvent extends GaliDesawarGameEvent {}

class RemoveOpenPlayBetEvent extends GaliDesawarGameEvent {
  final int index;
  RemoveOpenPlayBetEvent(this.index);
}

// ─────────────────────────────────────────────────────────────────────────────
// Jantri events
// ─────────────────────────────────────────────────────────────────────────────

/// Called whenever a cell value changes in the jantri grid.
class UpdateJantriBetEvent extends GaliDesawarGameEvent {
  final String betNumber;
  final String amountText;
  final BetType betType; // jodi / leftDigit (andar) / rightDigit (bahar)

  UpdateJantriBetEvent({
    required this.betNumber,
    required this.amountText,
    required this.betType,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Cross Game events
// ─────────────────────────────────────────────────────────────────────────────

/// Recalculate cross bets from raw digit string + amount.
class RecalculateCrossGameEvent extends GaliDesawarGameEvent {
  final String digitsText;
  final String amountText;

  RecalculateCrossGameEvent({
    required this.digitsText,
    required this.amountText,
  });
}

class ToggleCrossWithoutJodaEvent extends GaliDesawarGameEvent {}

class RemoveCrossBetEvent extends GaliDesawarGameEvent {
  final int index;
  RemoveCrossBetEvent(this.index);
}

// ─────────────────────────────────────────────────────────────────────────────
// Submit
// ─────────────────────────────────────────────────────────────────────────────

class SubmitGaliDesawarBetsEvent extends GaliDesawarGameEvent {}

// ─────────────────────────────────────────────────────────────────────────────
// Internal — wallet sync from AuthBloc stream
// ─────────────────────────────────────────────────────────────────────────────
//
class _SyncGaliWalletEvent extends GaliDesawarGameEvent {
  final int wallet;
  _SyncGaliWalletEvent(this.wallet);
}
