import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalyanboss/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kalyanboss/features/betting/config/game_type_config.dart';
import 'package:kalyanboss/features/betting/domain/entity/betting_entity.dart';
import 'package:kalyanboss/features/betting/domain/usecases/betting_use_cases.dart';
import 'package:kalyanboss/features/betting/presentation/bloc/unified_game_event.dart';
import 'package:kalyanboss/features/betting/presentation/bloc/unified_game_state.dart';
import 'package:kalyanboss/features/betting/utils/panna_validator.dart';
import 'package:kalyanboss/services/session_manager.dart';
import 'package:kalyanboss/utils/bloc/local_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// UnifiedGameBloc
// ─────────────────────────────────────────────────────────────────────────────
class UnifiedGameBloc extends Bloc<UnifiedGameEvent, UnifiedGameState> {
  final BettingUseCases bettingUseCases;
  final AuthBloc _authBloc;

  /// Listens to AuthBloc so wallet balance / bet limits stay in sync while
  /// the screen is open.
  late final StreamSubscription<AuthState> _authSubscription;

  UnifiedGameBloc({
    required this.bettingUseCases,
    required AuthBloc authBloc,
  })  : _authBloc = authBloc,
        super(const UnifiedGameState.initial()) {
    _authSubscription = _authBloc.stream.listen((authState) {
      add(_SyncAuthSettingsEvent(authState));
    });

    on<InitGameEvent>(_onInit);
    on<UpdateSessionEvent>(_onUpdateSession);
    on<AddSingleBetEvent>(_onAddSingle);
    on<AddBulkBetsEvent>(_onAddBulk);
    on<AddMotorBetsEvent>(_onAddMotor);
    on<RemoveBetEvent>(_onRemoveBet);
    on<ClearCartEvent>(_onClearCart);
    on<SubmitBetsEvent>(_onSubmit);
    on<_SyncAuthSettingsEvent>(_onSyncAuth);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  /// Extracts the [GameReadyData] from the current state, or null.
  GameReadyData? get _ready =>
      state.gameState.whenOrNull(success: (data) => data);

  String _newId() =>
      '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';

  BetSettings _settingsFromAuth(AuthState authState) {
    final userEntity =
    authState.userEntity?.whenOrNull(success: (data) => data);
    final settingEntity =
    authState.fetchSettingEntity?.whenOrNull(success: (data) => data);

    final wallet = userEntity?.wallet ?? 0;
    final bettingLimits = settingEntity?.data?.betting;

    return BetSettings(
      walletBalance: wallet,
      minBet: bettingLimits?.min ?? 10,
      maxBet: bettingLimits?.max ?? 5000,
    );
  }

  // ── Validation ───────────────────────────────────────────────────────────────

  String? _validatePoints(int points, BetSettings s) {
    if (points <= 0) return 'Points must be greater than 0';
    if (points < s.minBet) return 'Minimum bet is ₹${s.minBet}';
    if (points > s.maxBet) return 'Maximum bet is ₹${s.maxBet}';
    return null;
  }

  String? _validateOpenValue(String value, GameTypeConfig config) {
    final v = value.trim();
    switch (config.inputStyle) {
      case InputStyle.gridStyle:
        if (!PannaValidator.isValidSingleDigit(v)) {
          return 'Please select a digit between 0 and 9';
        }
      case InputStyle.inputStyle:
        if (config.digitCount == 2) {
          if (!PannaValidator.isValidJodi(v)) {
            return 'Jodi must be exactly 2 digits (00 – 99)';
          }
        } else if (config.digitCount == 3) {
          if (v.length != 3 || !RegExp(r'^\d{3}$').hasMatch(v)) {
            return 'Panna must be exactly 3 digits';
          }
          if (!PannaValidator.isValidForType(v, config.pannaType)) {
            return _pannaErrorMessage(config.pannaType);
          }
        }
      case InputStyle.sangamStyle:
        if (!config.hasDualPanna) {
          if (!PannaValidator.isValidSingleDigit(v)) {
            return 'Open digit must be between 0 and 9';
          }
        } else {
          if (!PannaValidator.isValidForType(v, config.pannaType)) {
            return _pannaErrorMessage(config.pannaType);
          }
        }
      default:
        break;
    }
    return null;
  }

  String? _validateCloseValue(String value, GameTypeConfig config) {
    if (config.inputStyle != InputStyle.sangamStyle) return null;
    final v = value.trim();
    if (!config.hasDualPanna) {
      if (v.length != 3 || !RegExp(r'^\d{3}$').hasMatch(v)) {
        return 'Panna must be exactly 3 digits';
      }
      if (!PannaValidator.isValidForType(v, config.pannaType)) {
        return _pannaErrorMessage(config.pannaType);
      }
    } else {
      if (!PannaValidator.isValidAnyPanna(v)) {
        return 'Close Panna is not valid';
      }
    }
    return null;
  }

  String _pannaErrorMessage(PannaType type) => switch (type) {
    PannaType.single =>
    'Invalid Single Panna — all 3 digits must be different',
    PannaType.double =>
    'Invalid Double Panna — exactly 2 of the 3 digits must be the same',
    PannaType.triple => 'Invalid Triple Panna — use 000, 111 … 999',
    PannaType.any => 'Not a valid Panna number',
    _ => 'Invalid value',
  };

  String _pannaTypeName(PannaType t) => switch (t) {
    PannaType.single => 'Single Panna',
    PannaType.double => 'Double Panna',
    PannaType.triple => 'Triple Panna',
    _ => 'Panna',
  };

  // ── Emit helpers ─────────────────────────────────────────────────────────────

  /// Emit a transient feedback message, then immediately follow it with the
  /// restored ready state so the BlocBuilder never blanks out.
  void _emitFeedback(
      Emitter<UnifiedGameState> emit,
      GameFeedback feedback,
      GameReadyData ready,
      ) {
    emit(state.copyWith(feedback: feedback));
    emit(state.copyWith(
      gameState: LocalState.success(ready),
      feedback: null,
    ));
  }

  // ── Session time helper ───────────────────────────────────────────────────────

  /// Returns true when the market's open time (format "HH:mm") has already
  /// passed relative to the current device time.
  bool _isOpenTimePassed(String openTime) {
    try {
      final parts = openTime.split(':');
      if (parts.length < 2) return false;
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final now = DateTime.now();
      final open = DateTime(now.year, now.month, now.day, hour, minute);
      return now.isAfter(open);
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Handlers
  // ─────────────────────────────────────────────────────────────────────────────

  Future<void> _onInit(
      InitGameEvent event, Emitter<UnifiedGameState> emit) async {
    emit(state.copyWith(gameState: const LocalState.loading(), feedback: null));
    try {
      final settings = _settingsFromAuth(_authBloc.state);
      final config = GameTypeConfig.fromGameName(event.gameMode.name);

      final openLocked = _isOpenTimePassed(event.market.openTime);

      // For open-only games the session is always "OPEN" regardless of time —
      // the backend / game config controls whether open-only games even appear
      // after open time. For dual-session games we force CLOSE when locked.
      final initialSession =
      (config.sessionType == SessionType.open || !openLocked)
          ? 'OPEN'
          : 'CLOSE';

      final readyData = GameReadyData(
        gameMode: event.gameMode,
        config: config,
        settings: settings,
        cart: const [],
        currentSession: initialSession,
        userId: event.userId,
        market: event.market,
        isOpenLocked: openLocked,
      );

      emit(state.copyWith(gameState: LocalState.success(readyData)));
    } catch (e) {
      emit(state.copyWith(
          gameState: LocalState.error('Failed to initialise game: $e')));
    }
  }

  void _onSyncAuth(
      _SyncAuthSettingsEvent event, Emitter<UnifiedGameState> emit) {
    final ready = _ready;
    if (ready == null) return;

    final freshSettings = _settingsFromAuth(event.authState);
    if (freshSettings == ready.settings) return;

    emit(state.copyWith(
        gameState: LocalState.success(ready.copyWith(settings: freshSettings))));
  }

  void _onUpdateSession(
      UpdateSessionEvent event, Emitter<UnifiedGameState> emit) {
    final ready = _ready;
    if (ready == null) return;
    // Silently reject an attempt to select OPEN when it is locked.
    if (event.session == 'OPEN' && ready.isOpenLocked) return;
    emit(state.copyWith(
        gameState:
        LocalState.success(ready.copyWith(currentSession: event.session))));
  }

  // ── Single bet ───────────────────────────────────────────────────────────────

  void _onAddSingle(
      AddSingleBetEvent event, Emitter<UnifiedGameState> emit) {
    final ready = _ready;
    if (ready == null) return;

    final pointsError = _validatePoints(event.points, ready.settings);
    if (pointsError != null) {
      _emitFeedback(emit,
          GameFeedback(type: FeedbackType.validationError, message: pointsError),
          ready);
      return;
    }

    final openError = _validateOpenValue(event.openValue, ready.config);
    if (openError != null) {
      _emitFeedback(emit,
          GameFeedback(type: FeedbackType.validationError, message: openError),
          ready);
      return;
    }

    final closeError = _validateCloseValue(event.closeValue, ready.config);
    if (closeError != null) {
      _emitFeedback(emit,
          GameFeedback(type: FeedbackType.validationError, message: closeError),
          ready);
      return;
    }

    final balanceError = _validateBalance(event.points, ready);
    if (balanceError != null) {
      _emitFeedback(emit,
          GameFeedback(type: FeedbackType.validationError, message: balanceError),
          ready);
      return;
    }

    final newBet = BetEntry(
      id: _newId(),
      userId: ready.userId,
      session: event.session,
      tag: ready.gameMode.name,
      openDigit: event.openValue.trim(),
      closeDigit: event.closeValue.trim(),
      points: event.points,
      gameMode: ready.gameMode.id,
      marketId: ready.marketId,
    );

    emit(state.copyWith(
        gameState: LocalState.success(
            ready.copyWith(cart: [...ready.cart, newBet]))));
  }

  // ── Bulk bets ─────────────────────────────────────────────────────────────────

  void _onAddBulk(AddBulkBetsEvent event, Emitter<UnifiedGameState> emit) {
    final ready = _ready;
    if (ready == null) return;

    final List<BetEntry> newBets = [];
    final List<String> errors = [];

    for (final entry in event.entries.entries) {
      final value = entry.key.trim();
      final points = entry.value;

      if (points == 0) continue;

      final pointsError = _validatePoints(points, ready.settings);
      if (pointsError != null) {
        errors.add('[$value] $pointsError');
        continue;
      }

      final valueError = _validateOpenValue(value, ready.config);
      if (valueError != null) {
        errors.add('[$value] $valueError');
        continue;
      }

      newBets.add(BetEntry(
        id: _newId(),
        userId: ready.userId,
        session: event.session,
        tag: ready.gameMode.name,
        openDigit: value,
        closeDigit: '',
        points: points,
        gameMode: ready.gameMode.id,
        marketId: ready.marketId,
      ));
    }

    if (errors.isNotEmpty) {
      // Emit the error feedback — followed by the current ready state (possibly
      // with the successfully parsed bets already added below, or the original).
    }

    if (newBets.isNotEmpty) {
      final totalAdded = newBets.fold(0, (s, b) => s + b.points);
      if (ready.totalPoints + totalAdded > ready.settings.walletBalance) {
        _emitFeedback(
          emit,
          const GameFeedback(
              type: FeedbackType.validationError,
              message: 'Total exceeds wallet balance'),
          ready,
        );
        return;
      }
      final updated = ready.copyWith(cart: [...ready.cart, ...newBets]);

      if (errors.isNotEmpty) {
        // Show errors but still commit the valid rows.
        emit(state.copyWith(
          gameState: LocalState.success(updated),
          feedback: GameFeedback(
            type: FeedbackType.validationError,
            message:
            '${errors.length} row(s) skipped:\n${errors.take(3).join('\n')}',
          ),
        ));
        // Clear feedback so listener fires exactly once.
        emit(state.copyWith(
            gameState: LocalState.success(updated), feedback: null));
      } else {
        emit(state.copyWith(gameState: LocalState.success(updated)));
      }
    } else if (errors.isEmpty) {
      _emitFeedback(
        emit,
        const GameFeedback(
            type: FeedbackType.validationError, message: 'No points entered'),
        ready,
      );
    } else {
      // Every row had an error — report and keep current state.
      _emitFeedback(
        emit,
        GameFeedback(
          type: FeedbackType.validationError,
          message:
          '${errors.length} row(s) skipped:\n${errors.take(3).join('\n')}',
        ),
        ready,
      );
    }
  }

  // ── Motor bets ────────────────────────────────────────────────────────────────

  void _onAddMotor(AddMotorBetsEvent event, Emitter<UnifiedGameState> emit) {
    final ready = _ready;
    if (ready == null) return;

    final pointsError =
    _validatePoints(event.pointsPerCombo, ready.settings);
    if (pointsError != null) {
      _emitFeedback(emit,
          GameFeedback(type: FeedbackType.validationError, message: pointsError),
          ready);
      return;
    }

    final combos = PannaValidator.expandMotorInput(
        event.rawInput, ready.config.pannaType);

    if (combos.isEmpty) {
      _emitFeedback(
        emit,
        GameFeedback(
          type: FeedbackType.validationError,
          message:
          'No valid ${_pannaTypeName(ready.config.pannaType)} combos found. '
              'Check your input and try again.',
        ),
        ready,
      );
      return;
    }

    final totalCost = combos.length * event.pointsPerCombo;
    if (ready.totalPoints + totalCost > ready.settings.walletBalance) {
      _emitFeedback(
        emit,
        GameFeedback(
          type: FeedbackType.validationError,
          message: 'This motor costs ₹$totalCost but you only have '
              '₹${ready.remainingBalance} remaining',
        ),
        ready,
      );
      return;
    }

    final newBets = combos
        .map((combo) => BetEntry(
      id: _newId(),
      userId: ready.userId,
      session: event.session,
      tag: ready.gameMode.name,
      openDigit: combo,
      closeDigit: '',
      points: event.pointsPerCombo,
      gameMode: ready.gameMode.id,
      marketId: ready.marketId,
    ))
        .toList();

    emit(state.copyWith(
        gameState: LocalState.success(
            ready.copyWith(cart: [...ready.cart, ...newBets]))));
  }

  // ── Remove / Clear ────────────────────────────────────────────────────────────

  void _onRemoveBet(RemoveBetEvent event, Emitter<UnifiedGameState> emit) {
    final ready = _ready;
    if (ready == null) return;
    emit(state.copyWith(
        gameState: LocalState.success(ready.copyWith(
            cart: ready.cart.where((b) => b.id != event.betId).toList()))));
  }

  void _onClearCart(ClearCartEvent event, Emitter<UnifiedGameState> emit) {
    final ready = _ready;
    if (ready == null) return;
    emit(state.copyWith(
        gameState: LocalState.success(ready.copyWith(cart: const []))));
  }

  // ── Submit ────────────────────────────────────────────────────────────────────

  Future<void> _onSubmit(
      SubmitBetsEvent event, Emitter<UnifiedGameState> emit) async {
    final ready = _ready;
    if (ready == null) return;

    if (ready.cart.isEmpty) {
      _emitFeedback(
        emit,
        const GameFeedback(
            type: FeedbackType.validationError,
            message: 'Add at least one bet before submitting'),
        ready,
      );
      return;
    }

    // Show the spinner inside the submit button.
    emit(state.copyWith(
        gameState: LocalState.success(ready.copyWith(isSubmitting: true))));

    try {
      final formattedGameMode =
      ready.gameMode.name.toLowerCase().replaceAll(' ', '-');

      final List<Map<String, dynamic>> betsList = ready.cart
          .map((bet) => {
        'user_id': SessionManager.instance.getUserId,
        'open_digit': bet.openDigit,
        'points': bet.points,
        'tag': 'roulette',
        'game_mode': formattedGameMode,
        'market_id': ready.marketId,
        'session': bet.session.toLowerCase(),
      })
          .toList();

      final result = await bettingUseCases.submitBetUseCase.call(betsList);

      result.fold(
            (success) {
          // Clear cart, stop spinner.
          final cleared = ready.copyWith(cart: const [], isSubmitting: false);

          // Emit success feedback, then settle on the cleared ready state.
          emit(state.copyWith(
            gameState: LocalState.success(cleared),
            feedback: GameFeedback(
              type: FeedbackType.submitSuccess,
              message: '${ready.cart.length} bet(s) placed successfully!',
              betsCount: ready.cart.length,
            ),
          ));
          emit(state.copyWith(
              gameState: LocalState.success(cleared), feedback: null));

          // Refresh wallet balance in the background.
          _authBloc.add(FetchProfileEvent());
        },
            (error) {
          final recovered = ready.copyWith(isSubmitting: false);
          emit(state.copyWith(
            gameState: LocalState.success(recovered),
            feedback: GameFeedback(
              type: FeedbackType.submitFailure,
              message: error.message.toString(),
            ),
          ));
          emit(state.copyWith(
              gameState: LocalState.success(recovered), feedback: null));
        },
      );
    } catch (e) {
      final recovered = ready.copyWith(isSubmitting: false);
      emit(state.copyWith(
        gameState: LocalState.success(recovered),
        feedback: GameFeedback(
          type: FeedbackType.submitFailure,
          message: e.toString(),
        ),
      ));
      emit(state.copyWith(
          gameState: LocalState.success(recovered), feedback: null));
    }
  }

  String? _validateBalance(int additionalPoints, GameReadyData ready) {
    final newTotal = ready.totalPoints + additionalPoints;
    if (newTotal > ready.settings.walletBalance) {
      return 'Insufficient balance — need ₹$additionalPoints, '
          'available ₹${ready.remainingBalance}';
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Disposal
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal event — fired by the AuthBloc stream listener, not the UI.
// ─────────────────────────────────────────────────────────────────────────────
class _SyncAuthSettingsEvent extends UnifiedGameEvent {
  final AuthState authState;

  const _SyncAuthSettingsEvent(this.authState);

  @override
  List<Object?> get props => [authState];
}