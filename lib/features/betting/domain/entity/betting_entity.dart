import 'package:equatable/equatable.dart';



// ─────────────────────────────────────────────────────────────────────────────
// BetEntry  (one item in the cart — maps directly to submission JSON)
// ─────────────────────────────────────────────────────────────────────────────
class BetEntry extends Equatable {
  final String id;         // local UUID for removal
  final String userId;
  final String session;    // "OPEN" | "CLOSE"
  final String tag;        // game-mode label (e.g. "JODI DIGIT")
  final String openDigit;  // digit / panna / jodi for open side
  final String closeDigit; // digit / panna for close side (empty if N/A)
  final int points;
  final String gameMode;   // game-mode _id from API
  final String marketId;

  const BetEntry({
    required this.id,
    required this.userId,
    required this.session,
    required this.tag,
    required this.openDigit,
    required this.closeDigit,
    required this.points,
    required this.gameMode,
    required this.marketId,
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'session': session,
    'tag': tag,
    'open_digit': openDigit,
    'close_digit': closeDigit,
    'points': points,
    'game_mode': gameMode,
    'market_id': marketId,
  };

  BetEntry copyWith({
    String? id,
    String? userId,
    String? session,
    String? tag,
    String? openDigit,
    String? closeDigit,
    int? points,
    String? gameMode,
    String? marketId,
  }) =>
      BetEntry(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        session: session ?? this.session,
        tag: tag ?? this.tag,
        openDigit: openDigit ?? this.openDigit,
        closeDigit: closeDigit ?? this.closeDigit,
        points: points ?? this.points,
        gameMode: gameMode ?? this.gameMode,
        marketId: marketId ?? this.marketId,
      );

  @override
  List<Object?> get props =>
      [id, session, tag, openDigit, closeDigit, points, gameMode, marketId];
}

// ─────────────────────────────────────────────────────────────────────────────
// BetSettings  (fetched from settings API)
// ─────────────────────────────────────────────────────────────────────────────
class BetSettings extends Equatable {
  final int minBet;
  final int maxBet;
  final int walletBalance;

  const BetSettings({
    required this.minBet,
    required this.maxBet,
    required this.walletBalance,
  });

  factory BetSettings.defaults() =>
      const BetSettings(minBet: 10, maxBet: 5000, walletBalance: 0);

  factory BetSettings.fromJson(Map<String, dynamic> json) {
    return BetSettings(
      minBet: (json['min_bet'] as num).toInt(),
      maxBet: (json['max_bet'] as num).toInt(),
      walletBalance: (json['wallet_balance'] as num).toInt(),
    );
  }

  @override
  List<Object?> get props => [minBet, maxBet, walletBalance];
}
