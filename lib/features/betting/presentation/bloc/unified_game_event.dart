import 'package:equatable/equatable.dart';
import 'package:kalyanboss/features/betting/domain/entity/betting_entity.dart';
import 'package:kalyanboss/features/game/domain/entity/game_mode_entity.dart';
import 'package:kalyanboss/features/game/domain/entity/market_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Base
// ─────────────────────────────────────────────────────────────────────────────
abstract class UnifiedGameEvent extends Equatable {
  const UnifiedGameEvent();

  @override
  List<Object?> get props => [];
}

// ─────────────────────────────────────────────────────────────────────────────
// Initialisation
// ─────────────────────────────────────────────────────────────────────────────

/// Called when the screen opens. Loads settings and primes the BLoC.
class InitGameEvent extends UnifiedGameEvent {
  final GameModeEntity gameMode;
  final MarketEntity market;
  final String userId;

  const InitGameEvent({
    required this.gameMode,
    required this.market,
    required this.userId,
  });

  @override
  List<Object?> get props => [gameMode, market, userId];
}

// ─────────────────────────────────────────────────────────────────────────────
// Session
// ─────────────────────────────────────────────────────────────────────────────

class UpdateSessionEvent extends UnifiedGameEvent {
  /// "OPEN" or "CLOSE"
  final String session;

  const UpdateSessionEvent(this.session);

  @override
  List<Object?> get props => [session];
}

// ─────────────────────────────────────────────────────────────────────────────
// Cart mutations
// ─────────────────────────────────────────────────────────────────────────────

/// Add a single validated bet (all non-bulk, non-motor modes).
class AddSingleBetEvent extends UnifiedGameEvent {
  final String openValue;
  final String closeValue;
  final int points;
  final String session;

  const AddSingleBetEvent({
    required this.openValue,
    required this.closeValue,
    required this.points,
    required this.session,
  });

  @override
  List<Object?> get props => [openValue, closeValue, points, session];
}

/// Add all rows from a bulk grid at once.
class AddBulkBetsEvent extends UnifiedGameEvent {
  /// key = digit/jodi/panna value, value = points (0 = skip).
  final Map<String, int> entries;
  final String session;

  const AddBulkBetsEvent({required this.entries, required this.session});

  @override
  List<Object?> get props => [entries, session];
}

/// Expand motor input and add one bet per generated combination.
class AddMotorBetsEvent extends UnifiedGameEvent {
  /// Raw comma-separated user input e.g. "123, 456".
  final String rawInput;
  final int pointsPerCombo;
  final String session;

  const AddMotorBetsEvent({
    required this.rawInput,
    required this.pointsPerCombo,
    required this.session,
  });

  @override
  List<Object?> get props => [rawInput, pointsPerCombo, session];
}

/// Remove a single bet from the cart by its local id.
class RemoveBetEvent extends UnifiedGameEvent {
  final String betId;

  const RemoveBetEvent(this.betId);

  @override
  List<Object?> get props => [betId];
}

/// Wipe the whole cart.
class ClearCartEvent extends UnifiedGameEvent {
  const ClearCartEvent();
}

// ─────────────────────────────────────────────────────────────────────────────
// Submission
// ─────────────────────────────────────────────────────────────────────────────

class SubmitBetsEvent extends UnifiedGameEvent {
  const SubmitBetsEvent();
}