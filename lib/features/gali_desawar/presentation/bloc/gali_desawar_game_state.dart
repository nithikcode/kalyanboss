part of 'gali_desawar_game_bloc.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Top-level state — one flat object, same pattern as UnifiedGameState
// ─────────────────────────────────────────────────────────────────────────────
class GaliDesawarGameState {
  /// Lifecycle of the active game session.
  final LocalState<GaliDesawarReadyData> gameState;

  /// Short-lived snack/feedback consumed by BlocListener only.
  final GaliDesawarFeedback? feedback;

  const GaliDesawarGameState({
    required this.gameState,
    this.feedback,
  });

  const GaliDesawarGameState.initial()
      : gameState = const LocalState.initial(),
        feedback = null;

  GaliDesawarGameState copyWith({
    LocalState<GaliDesawarReadyData>? gameState,
    Object? feedback = _sentinel,
  }) {
    return GaliDesawarGameState(
      gameState: gameState ?? this.gameState,
      feedback: identical(feedback, _sentinel)
          ? this.feedback
          : feedback as GaliDesawarFeedback?,
    );
  }
}

const _sentinel = Object();

// ─────────────────────────────────────────────────────────────────────────────
// GaliDesawarReadyData — payload inside LocalState.success
// ─────────────────────────────────────────────────────────────────────────────
class GaliDesawarReadyData {
  final MarketEntity market;
  final String tag;
  final String userId;
  final int walletBalance;

  // ── Active game mode ───────────────────────────────────────────────────────
  final GaliDesawarMode activeMode;

  // ── Open Play ──────────────────────────────────────────────────────────────
  final List<GaliDesawarBet> openPlayBets;
  final bool openPlayWithPalti;
  final bool openPlayHarupAndar;
  final bool openPlayHarupBahar;

  // ── Jantri ─────────────────────────────────────────────────────────────────
  final List<GaliDesawarBet> jantriBets;

  // ── Cross Game ─────────────────────────────────────────────────────────────
  final List<GaliDesawarBet> crossBets;
  final bool crossWithoutJoda;

  // ── Submission flag ────────────────────────────────────────────────────────
  final bool isSubmitting;

  const GaliDesawarReadyData({
    required this.market,
    required this.tag,
    required this.userId,
    required this.walletBalance,
    this.activeMode = GaliDesawarMode.openPlay,
    this.openPlayBets = const [],
    this.openPlayWithPalti = false,
    this.openPlayHarupAndar = false,
    this.openPlayHarupBahar = false,
    this.jantriBets = const [],
    this.crossBets = const [],
    this.crossWithoutJoda = false,
    this.isSubmitting = false,
  });

  // ── Derived ──────────────────────────────────────────────────────────────────

  List<GaliDesawarBet> get activeBets => switch (activeMode) {
        GaliDesawarMode.openPlay => openPlayBets,
        GaliDesawarMode.jantri => jantriBets,
        GaliDesawarMode.cross => crossBets,
      };

  int get totalAmount =>
      activeBets.fold(0, (sum, b) => sum + b.betAmount);

  int get remainingBalance => walletBalance - totalAmount;

  bool get canSubmit => activeBets.isNotEmpty && !isSubmitting;

  // ── copyWith ─────────────────────────────────────────────────────────────────

  GaliDesawarReadyData copyWith({
    MarketEntity? market,
    String? tag,
    String? userId,
    int? walletBalance,
    GaliDesawarMode? activeMode,
    List<GaliDesawarBet>? openPlayBets,
    bool? openPlayWithPalti,
    bool? openPlayHarupAndar,
    bool? openPlayHarupBahar,
    List<GaliDesawarBet>? jantriBets,
    List<GaliDesawarBet>? crossBets,
    bool? crossWithoutJoda,
    bool? isSubmitting,
  }) =>
      GaliDesawarReadyData(
        market: market ?? this.market,
        tag: tag ?? this.tag,
        userId: userId ?? this.userId,
        walletBalance: walletBalance ?? this.walletBalance,
        activeMode: activeMode ?? this.activeMode,
        openPlayBets: openPlayBets ?? this.openPlayBets,
        openPlayWithPalti: openPlayWithPalti ?? this.openPlayWithPalti,
        openPlayHarupAndar: openPlayHarupAndar ?? this.openPlayHarupAndar,
        openPlayHarupBahar: openPlayHarupBahar ?? this.openPlayHarupBahar,
        jantriBets: jantriBets ?? this.jantriBets,
        crossBets: crossBets ?? this.crossBets,
        crossWithoutJoda: crossWithoutJoda ?? this.crossWithoutJoda,
        isSubmitting: isSubmitting ?? this.isSubmitting,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// GaliDesawarBet — a single bet entry in any mode's cart
// ─────────────────────────────────────────────────────────────────────────────
class GaliDesawarBet {
  final String betNumber;   // e.g. "23", "5", "07"
  final int betAmount;
  final BetType betType;    // jodi / left / right
  // isHarupNumber is inferred from betType
  const GaliDesawarBet({
    required this.betNumber,
    required this.betAmount,
    required this.betType,
  });

  GaliDesawarBet copyWith({int? betAmount}) => GaliDesawarBet(
        betNumber: betNumber,
        betAmount: betAmount ?? this.betAmount,
        betType: betType,
      );
}

enum GaliDesawarMode { openPlay, jantri, cross }

enum BetType { jodi, leftDigit, rightDigit }

// ─────────────────────────────────────────────────────────────────────────────
// Feedback — transient, consumed by BlocListener
// ─────────────────────────────────────────────────────────────────────────────
enum GaliFeedbackType { error, success }

class GaliDesawarFeedback {
  final GaliFeedbackType type;
  final String message;

  const GaliDesawarFeedback({required this.type, required this.message});

  bool get isError => type == GaliFeedbackType.error;
}
