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

// ─────────────────────────────────────────────────────────────────────────────
// UnifiedGameBloc
// ─────────────────────────────────────────────────────────────────────────────
class UnifiedGameBloc extends Bloc<UnifiedGameEvent, UnifiedGameState> {
  final BettingUseCases bettingUseCases;
  final AuthBloc _authBloc;

  /// Tracks the last stable [GameReadyState] so transient states (validation
  /// errors, submit success/failure) can always snap back to it without the
  /// risk of emitting a null ready state.
  GameReadyState? _lastReadyState;

  /// Listens to AuthBloc so wallet balance / bet limits stay in sync while
  /// the screen is open — but ONLY updates existing ready state, never causes
  /// a GoRouter refresh (that is handled by the filtered stream in routes.dart).
  late final StreamSubscription<AuthState> _authSubscription;

  UnifiedGameBloc({
    required this.bettingUseCases,
    required AuthBloc authBloc,
  })  : _authBloc = authBloc,
        super(const GameLoadingState()) {
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

  // ── Helpers ─────────────────────────────────────────────────────────────────

  /// Returns the current ready state OR the last cached one. Never null after
  /// a successful init — callers still guard with early return when null.
  GameReadyState? get _ready {
    if (state is GameReadyState) {
      _lastReadyState = state as GameReadyState;
      return _lastReadyState;
    }
    // Return cached ready state so transient states don't lose context.
    return _lastReadyState;
  }

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

  // ── Validation ──────────────────────────────────────────────────────────────

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

  String? _validateBalance(int additionalPoints, GameReadyState ready) {
    final newTotal = ready.totalPoints + additionalPoints;
    if (newTotal > ready.settings.walletBalance) {
      return 'Insufficient balance — need ₹$additionalPoints, '
          'available ₹${ready.remainingBalance}';
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Handlers
  // ─────────────────────────────────────────────────────────────────────────────

  Future<void> _onInit(
      InitGameEvent event, Emitter<UnifiedGameState> emit) async {
    emit(const GameLoadingState());
    try {
      final settings = _settingsFromAuth(_authBloc.state);
      final config = GameTypeConfig.fromGameName(event.gameMode.name);

      final readyState = GameReadyState(
        gameMode: event.gameMode,
        config: config,
        settings: settings,
        cart: const [],
        currentSession: 'OPEN',
        userId: event.userId,
        marketId: event.marketId,
      );

      // Cache immediately so transient states can always recover.
      _lastReadyState = readyState;
      emit(readyState);
    } catch (e) {
      emit(GameErrorState('Failed to initialise game: $e'));
    }
  }

  void _onSyncAuth(
      _SyncAuthSettingsEvent event, Emitter<UnifiedGameState> emit) {
    // Use cached ready state — this fires even during transient states like
    // GameSubmitSuccessState, so we must NOT use `state is GameReadyState`.
    final ready = _lastReadyState;
    if (ready == null) return;

    final freshSettings = _settingsFromAuth(event.authState);
    if (freshSettings == ready.settings) return;

    final updated = ready.copyWith(settings: freshSettings);
    _lastReadyState = updated;

    // Only emit if current visible state is also GameReadyState to avoid
    // clobbering a transient state that's being displayed right now.
    if (state is GameReadyState) {
      emit(updated);
    }
  }

  void _onUpdateSession(
      UpdateSessionEvent event, Emitter<UnifiedGameState> emit) {
    final ready = _ready;
    if (ready == null) return;
    final updated = ready.copyWith(currentSession: event.session);
    _lastReadyState = updated;
    emit(updated);
  }

  // ── Single bet ──────────────────────────────────────────────────────────────

  void _onAddSingle(
      AddSingleBetEvent event, Emitter<UnifiedGameState> emit) {
    final ready = _ready;
    if (ready == null) return;

    final pointsError = _validatePoints(event.points, ready.settings);
    if (pointsError != null) {
      emit(GameValidationErrorState(pointsError));
      emit(ready); // always restore — _ready returns cached state
      return;
    }

    final openError = _validateOpenValue(event.openValue, ready.config);
    if (openError != null) {
      emit(GameValidationErrorState(openError));
      emit(ready);
      return;
    }

    if (ready.config.inputStyle == InputStyle.sangamStyle) {
      final closeError = _validateCloseValue(event.closeValue, ready.config);
      if (closeError != null) {
        emit(GameValidationErrorState(closeError));
        emit(ready);
        return;
      }
    }

    final balError = _validateBalance(event.points, ready);
    if (balError != null) {
      emit(GameValidationErrorState(balError));
      emit(ready);
      return;
    }

    final bet = BetEntry(
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

    final updated = ready.copyWith(cart: [...ready.cart, bet]);
    _lastReadyState = updated;
    emit(updated);
  }

  // ── Bulk bets ───────────────────────────────────────────────────────────────

  void _onAddBulk(
      AddBulkBetsEvent event, Emitter<UnifiedGameState> emit) {
    final ready = _ready;
    if (ready == null) return;

    final newBets = <BetEntry>[];
    final errors = <String>[];

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
      emit(GameValidationErrorState(
          '${errors.length} row(s) skipped:\n${errors.take(3).join('\n')}'));
    }

    if (newBets.isNotEmpty) {
      final totalAdded = newBets.fold(0, (s, b) => s + b.points);
      if (ready.totalPoints + totalAdded > ready.settings.walletBalance) {
        emit(const GameValidationErrorState('Total exceeds wallet balance'));
        emit(ready);
        return;
      }
      final updated = ready.copyWith(cart: [...ready.cart, ...newBets]);
      _lastReadyState = updated;
      emit(updated);
    } else if (errors.isEmpty) {
      emit(const GameValidationErrorState('No points entered'));
      emit(ready);
    } else {
      // All rows had errors — restore ready so UI doesn't blank out.
      emit(ready);
    }
  }

  // ── Motor bets ──────────────────────────────────────────────────────────────

  void _onAddMotor(
      AddMotorBetsEvent event, Emitter<UnifiedGameState> emit) {
    final ready = _ready;
    if (ready == null) return;

    final pointsError =
    _validatePoints(event.pointsPerCombo, ready.settings);
    if (pointsError != null) {
      emit(GameValidationErrorState(pointsError));
      emit(ready);
      return;
    }

    final combos =
    PannaValidator.expandMotorInput(event.rawInput, ready.config.pannaType);

    if (combos.isEmpty) {
      emit(GameValidationErrorState(
          'No valid ${_pannaTypeName(ready.config.pannaType)} combos found. '
              'Check your input and try again.'));
      emit(ready);
      return;
    }

    final totalCost = combos.length * event.pointsPerCombo;
    if (ready.totalPoints + totalCost > ready.settings.walletBalance) {
      emit(GameValidationErrorState(
          'This motor costs ₹$totalCost but you only have '
              '₹${ready.remainingBalance} remaining'));
      emit(ready);
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

    final updated = ready.copyWith(cart: [...ready.cart, ...newBets]);
    _lastReadyState = updated;
    emit(updated);
  }

  // ── Remove ──────────────────────────────────────────────────────────────────

  void _onRemoveBet(
      RemoveBetEvent event, Emitter<UnifiedGameState> emit) {
    final ready = _ready;
    if (ready == null) return;
    final updated = ready.copyWith(
        cart: ready.cart.where((b) => b.id != event.betId).toList());
    _lastReadyState = updated;
    emit(updated);
  }

  void _onClearCart(ClearCartEvent event, Emitter<UnifiedGameState> emit) {
    final ready = _ready;
    if (ready == null) return;
    final updated = ready.copyWith(cart: const []);
    _lastReadyState = updated;
    emit(updated);
  }

  // ── Submit ──────────────────────────────────────────────────────────────────

  Future<void> _onSubmit(
      SubmitBetsEvent event, Emitter<UnifiedGameState> emit) async {
    final ready = _ready;
    if (ready == null) return;

    if (ready.cart.isEmpty) {
      emit(const GameValidationErrorState(
          'Add at least one bet before submitting'));
      emit(ready);
      return;
    }

    // Show loading indicator inside the button.
    final submittingState = ready.copyWith(isSubmitting: true);
    _lastReadyState = submittingState;
    emit(submittingState);

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

     result.fold((success){
       // ── Success path ──────────────────────────────────────────────────────
       // 1. Build the cleared ready state FIRST and cache it.
       final clearedState = ready.copyWith(cart: const [], isSubmitting: false);
       _lastReadyState = clearedState;

       // 2. Emit the transient success notification (caught by BlocListener).
       emit(GameSubmitSuccessState(
         message: '${ready.cart.length} bet(s) placed successfully!',
         betsCount: ready.cart.length,
       ));

       // 3. Restore to cleared ready state.
       emit(clearedState);

       // 4. Refresh wallet in background — does NOT trigger GoRouter refresh
       //    because routes.dart now only listens to auth-change events.
       _authBloc.add(FetchProfileEvent());
     }, (error){
       // ── Failure path ──────────────────────────────────────────────────────
       // 1. Build the recovered ready state and cache it.
       final recoveredState = ready.copyWith(isSubmitting: false);
       _lastReadyState = recoveredState;

       // 2. Emit the transient failure notification (caught by BlocListener).
       emit(GameSubmitFailureState(error.message.toString()));

       // 3. Restore to the same ready state so the user can fix & retry.
       emit(recoveredState);
     });


    } catch (e) {
      // ── Failure path ──────────────────────────────────────────────────────
      // 1. Build the recovered ready state and cache it.
      final recoveredState = ready.copyWith(isSubmitting: false);
      _lastReadyState = recoveredState;

      // 2. Emit the transient failure notification (caught by BlocListener).
      emit(GameSubmitFailureState(e.toString()));

      // 3. Restore to the same ready state so the user can fix & retry.
      emit(recoveredState);
    }
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