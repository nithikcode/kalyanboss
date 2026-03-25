import 'package:equatable/equatable.dart';
import 'package:kalyanboss/features/betting/domain/entity/betting_entity.dart';
import 'package:kalyanboss/features/game/domain/entity/game_mode_entity.dart';
import '../../config/game_type_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Base
// ─────────────────────────────────────────────────────────────────────────────
abstract class UnifiedGameState extends Equatable {
  const UnifiedGameState();

  @override
  List<Object?> get props => [];
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading — shown while settings are being read on screen open
// ─────────────────────────────────────────────────────────────────────────────
class GameLoadingState extends UnifiedGameState {
  const GameLoadingState();
}

// ─────────────────────────────────────────────────────────────────────────────
// Ready — the primary working state that owns the cart and settings
// ─────────────────────────────────────────────────────────────────────────────
class GameReadyState extends UnifiedGameState {
  final GameModeEntity gameMode;
  final GameTypeConfig config;
  final BetSettings settings;
  final List<BetEntry> cart;
  final String currentSession; // "OPEN" | "CLOSE"
  final String userId;
  final String marketId;

  /// True while a submit network call is in-flight. Used to show a spinner
  /// inside the submit button and disable it to prevent double-tap.
  final bool isSubmitting;

  const GameReadyState({
    required this.gameMode,
    required this.config,
    required this.settings,
    required this.cart,
    required this.currentSession,
    required this.userId,
    required this.marketId,
    this.isSubmitting = false,
  });

  // ── Derived ─────────────────────────────────────────────────────────────────

  int get totalPoints => cart.fold(0, (sum, e) => sum + e.points);
  int get remainingBalance => settings.walletBalance - totalPoints;
  bool get canSubmit => cart.isNotEmpty && remainingBalance >= 0;

  // ── copyWith ────────────────────────────────────────────────────────────────

  GameReadyState copyWith({
    GameModeEntity? gameMode,
    GameTypeConfig? config,
    BetSettings? settings,
    List<BetEntry>? cart,
    String? currentSession,
    String? userId,
    String? marketId,
    bool? isSubmitting,
  }) =>
      GameReadyState(
        gameMode: gameMode ?? this.gameMode,
        config: config ?? this.config,
        settings: settings ?? this.settings,
        cart: cart ?? this.cart,
        currentSession: currentSession ?? this.currentSession,
        userId: userId ?? this.userId,
        marketId: marketId ?? this.marketId,
        isSubmitting: isSubmitting ?? this.isSubmitting,
      );

  @override
  List<Object?> get props => [
    gameMode,
    config,
    settings,
    cart,
    currentSession,
    userId,
    marketId,
    isSubmitting,
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Transient feedback states — handled exclusively via BlocListener.
// The BlocBuilder always uses buildWhen to skip these so the UI never blanks.
// ─────────────────────────────────────────────────────────────────────────────

/// Emitted when user input fails validation. Always followed by the previous
/// [GameReadyState] so the UI reverts without any visible flicker.
class GameValidationErrorState extends UnifiedGameState {
  final String message;

  const GameValidationErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

/// Emitted once after a successful bet submission. Always followed by a fresh
/// [GameReadyState] with an empty cart.
class GameSubmitSuccessState extends UnifiedGameState {
  final String message;
  final int betsCount;

  const GameSubmitSuccessState({
    required this.message,
    required this.betsCount,
  });

  @override
  List<Object?> get props => [message, betsCount];
}

/// Emitted once when the submit network call fails. Always followed by the
/// previous [GameReadyState] so the user can retry.
class GameSubmitFailureState extends UnifiedGameState {
  final String message;

  const GameSubmitFailureState(this.message);

  @override
  List<Object?> get props => [message];
}

/// Emitted when a non-recoverable error occurs (e.g. init failure).
class GameErrorState extends UnifiedGameState {
  final String message;

  const GameErrorState(this.message);

  @override
  List<Object?> get props => [message];
}