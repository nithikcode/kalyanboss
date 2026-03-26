import 'package:equatable/equatable.dart';
import 'package:kalyanboss/features/betting/domain/entity/betting_entity.dart';
import 'package:kalyanboss/features/game/domain/entity/game_mode_entity.dart';
import 'package:kalyanboss/features/game/domain/entity/market_entity.dart';
import 'package:kalyanboss/utils/bloc/local_state.dart';
import '../../config/game_type_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Top-level state class — a single, flat object (no sealed hierarchy needed).
//
// The [gameState] field uses [LocalState] to express the lifecycle:
//   • initial  → screen not yet initialised
//   • loading  → init in progress
//   • success  → ready to play, carries [GameReadyData]
//   • error    → non-recoverable init failure
//   • refreshing → re-init while stale data is still shown
//
// Transient feedback (validation errors, submit result) is carried by the
// [feedback] field so the BlocBuilder never has to rebuild for them.
// ─────────────────────────────────────────────────────────────────────────────
class UnifiedGameState extends Equatable {
  /// Core lifecycle state for the game session.
  final LocalState<GameReadyData> gameState;

  /// Short-lived feedback shown via BlocListener (snackbars, toasts).
  /// Always set back to null after the listener has consumed it.
  final GameFeedback? feedback;

  const UnifiedGameState({
    required this.gameState,
    this.feedback,
  });

  // ── Factory constructors (named, for readability at call sites) ───────────

  const UnifiedGameState.initial()
      : gameState = const LocalState.initial(),
        feedback = null;

  // ── copyWith ─────────────────────────────────────────────────────────────────

  UnifiedGameState copyWith({
    LocalState<GameReadyData>? gameState,
    // Use an explicit sentinel so callers can set feedback to null.
    Object? feedback = _sentinel,
  }) {
    return UnifiedGameState(
      gameState: gameState ?? this.gameState,
      feedback: identical(feedback, _sentinel)
          ? this.feedback
          : feedback as GameFeedback?,
    );
  }

  @override
  List<Object?> get props => [gameState, feedback];
}

// Sentinel object so copyWith can distinguish "not passed" from "null".
const _sentinel = Object();

// ─────────────────────────────────────────────────────────────────────────────
// GameReadyData — the payload inside LocalState.success(...)
// ─────────────────────────────────────────────────────────────────────────────
class GameReadyData extends Equatable {
  final GameModeEntity gameMode;
  final GameTypeConfig config;
  final BetSettings settings;
  final List<BetEntry> cart;
  final String currentSession; // "OPEN" | "CLOSE"
  final String userId;
  final MarketEntity market;

  /// True when the market's open time has already passed today.
  /// When true, the OPEN session button is locked and currentSession is
  /// forced to "CLOSE" for games that support both sessions.
  final bool isOpenLocked;

  /// True while a submit network call is in-flight.
  final bool isSubmitting;

  const GameReadyData({
    required this.gameMode,
    required this.config,
    required this.settings,
    required this.cart,
    required this.currentSession,
    required this.userId,
    required this.market,
    required this.isOpenLocked,
    this.isSubmitting = false,
  });

  // ── Convenience ──────────────────────────────────────────────────────────────

  String get marketId => market.id;

  // ── Derived ──────────────────────────────────────────────────────────────────

  int get totalPoints => cart.fold(0, (sum, e) => sum + e.points);
  int get remainingBalance => settings.walletBalance - totalPoints;
  bool get canSubmit => cart.isNotEmpty && remainingBalance >= 0;

  // ── copyWith ─────────────────────────────────────────────────────────────────

  GameReadyData copyWith({
    GameModeEntity? gameMode,
    GameTypeConfig? config,
    BetSettings? settings,
    List<BetEntry>? cart,
    String? currentSession,
    String? userId,
    MarketEntity? market,
    bool? isOpenLocked,
    bool? isSubmitting,
  }) =>
      GameReadyData(
        gameMode: gameMode ?? this.gameMode,
        config: config ?? this.config,
        settings: settings ?? this.settings,
        cart: cart ?? this.cart,
        currentSession: currentSession ?? this.currentSession,
        userId: userId ?? this.userId,
        market: market ?? this.market,
        isOpenLocked: isOpenLocked ?? this.isOpenLocked,
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
    market,
    isOpenLocked,
    isSubmitting,
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// GameFeedback — transient messages consumed exclusively by BlocListener.
// ─────────────────────────────────────────────────────────────────────────────
enum FeedbackType { validationError, submitSuccess, submitFailure }

class GameFeedback extends Equatable {
  final FeedbackType type;
  final String message;
  final int? betsCount; // only relevant for submitSuccess

  const GameFeedback({
    required this.type,
    required this.message,
    this.betsCount,
  });

  bool get isError =>
      type == FeedbackType.validationError ||
          type == FeedbackType.submitFailure;

  @override
  List<Object?> get props => [type, message, betsCount];
}