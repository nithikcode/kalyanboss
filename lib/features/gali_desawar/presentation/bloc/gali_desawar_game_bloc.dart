import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalyanboss/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kalyanboss/features/betting/domain/usecases/betting_use_cases.dart';
import 'package:kalyanboss/features/game/domain/entity/market_entity.dart';
import 'package:kalyanboss/services/session_manager.dart';
import 'package:kalyanboss/utils/bloc/local_state.dart';

part 'gali_desawar_game_event.dart';
part 'gali_desawar_game_state.dart';

class GaliDesawarGameBloc
    extends Bloc<GaliDesawarGameEvent, GaliDesawarGameState> {
  final BettingUseCases bettingUseCases;
  final AuthBloc _authBloc;

  late final StreamSubscription<AuthState> _authSubscription;

  GaliDesawarGameBloc({
    required this.bettingUseCases,
    required AuthBloc authBloc,
  })  : _authBloc = authBloc,
        super(const GaliDesawarGameState.initial()) {
    // Keep wallet balance in sync whenever AuthBloc emits a new profile.
    _authSubscription = _authBloc.stream.listen((authState) {
      final wallet =
          authState.userEntity?.whenOrNull(success: (u) => u.wallet);
      if (wallet != null) add(_SyncGaliWalletEvent(wallet));
    });

    on<InitGaliDesawarGameEvent>(_onInit);
    on<SwitchGaliModeEvent>(_onSwitchMode);

    // Open Play
    on<RecalculateOpenPlayEvent>(_onRecalculateOpenPlay);
    on<ToggleOpenPlayPaltiEvent>(_onTogglePalti);
    on<ToggleOpenPlayHarupAndarEvent>(_onToggleHarupAndar);
    on<ToggleOpenPlayHarupBaharEvent>(_onToggleHarupBahar);
    on<RemoveOpenPlayBetEvent>(_onRemoveOpenPlayBet);

    // Jantri
    on<UpdateJantriBetEvent>(_onUpdateJantriBet);

    // Cross
    on<RecalculateCrossGameEvent>(_onRecalculateCross);
    on<ToggleCrossWithoutJodaEvent>(_onToggleCrossWithoutJoda);
    on<RemoveCrossBetEvent>(_onRemoveCrossBet);

    // Submit
    on<SubmitGaliDesawarBetsEvent>(_onSubmit);

    // Internal
    on<_SyncGaliWalletEvent>(_onSyncWallet);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  GaliDesawarReadyData? get _ready =>
      state.gameState.whenOrNull(success: (d) => d);

  void _emitSuccess(Emitter<GaliDesawarGameState> emit, GaliDesawarReadyData data) =>
      emit(state.copyWith(gameState: LocalState.success(data)));

  void _emitFeedback(
    Emitter<GaliDesawarGameState> emit,
    GaliDesawarFeedback feedback,
    GaliDesawarReadyData ready,
  ) {
    emit(state.copyWith(
        gameState: LocalState.success(ready), feedback: feedback));
    emit(state.copyWith(
        gameState: LocalState.success(ready), feedback: null));
  }

  // ── Init ─────────────────────────────────────────────────────────────────────

  void _onInit(
      InitGaliDesawarGameEvent event, Emitter<GaliDesawarGameState> emit) {
    emit(state.copyWith(gameState: const LocalState.loading()));

    final wallet = _authBloc.state.userEntity
            ?.whenOrNull(success: (u) => u.wallet) ??
        0;

    final data = GaliDesawarReadyData(
      market: event.market,
      tag: event.tag,
      userId: event.userId,
      walletBalance: wallet,
    );

    _emitSuccess(emit, data);
  }

  // ── Mode switch ───────────────────────────────────────────────────────────────

  void _onSwitchMode(
      SwitchGaliModeEvent event, Emitter<GaliDesawarGameState> emit) {
    final ready = _ready;
    if (ready == null) return;
    _emitSuccess(emit, ready.copyWith(activeMode: event.mode));
  }

  // ── Open Play ────────────────────────────────────────────────────────────────

  void _onRecalculateOpenPlay(
      RecalculateOpenPlayEvent event, Emitter<GaliDesawarGameState> emit) {
    final ready = _ready;
    if (ready == null) return;

    final bets = <GaliDesawarBet>[];

    // ── Jodi pairs ────────────────────────────────────────────────────────────
    final amount = int.tryParse(event.amountText.trim()) ?? 0;
    if (event.numbersText.isNotEmpty && amount > 0) {
      final pairs = _splitPairs(event.numbersText);
      final uniquePairs = pairs.toSet().toList();
      for (final pair in uniquePairs) {
        bets.add(GaliDesawarBet(
            betNumber: pair, betAmount: amount, betType: BetType.jodi));
        if (ready.openPlayWithPalti) {
          final reversed = pair.split('').reversed.join();
          if (reversed != pair) {
            bets.add(GaliDesawarBet(
                betNumber: reversed, betAmount: amount, betType: BetType.jodi));
          }
        }
      }
    }

    // ── Harup ─────────────────────────────────────────────────────────────────
    final harupAmount = int.tryParse(event.harupAmountText.trim()) ?? 0;
    final hasAndar = ready.openPlayHarupAndar;
    final hasBahar = ready.openPlayHarupBahar;

    if (event.harupText.isNotEmpty &&
        harupAmount > 0 &&
        (hasAndar || hasBahar)) {
      final digits = event.harupText.split('').toSet();
      final effectiveAmount =
          (hasAndar && hasBahar) ? harupAmount * 2 : harupAmount;

      for (final digit in digits) {
        bets.add(GaliDesawarBet(
          betNumber: digit,
          betAmount: effectiveAmount,
          betType: hasAndar ? BetType.leftDigit : BetType.rightDigit,
        ));
      }
    }

    _emitSuccess(emit, ready.copyWith(openPlayBets: bets));
  }

  void _onTogglePalti(
      ToggleOpenPlayPaltiEvent event, Emitter<GaliDesawarGameState> emit) {
    final ready = _ready;
    if (ready == null) return;
    _emitSuccess(
        emit, ready.copyWith(openPlayWithPalti: !ready.openPlayWithPalti));
  }

  void _onToggleHarupAndar(ToggleOpenPlayHarupAndarEvent event,
      Emitter<GaliDesawarGameState> emit) {
    final ready = _ready;
    if (ready == null) return;
    _emitSuccess(emit,
        ready.copyWith(openPlayHarupAndar: !ready.openPlayHarupAndar));
  }

  void _onToggleHarupBahar(ToggleOpenPlayHarupBaharEvent event,
      Emitter<GaliDesawarGameState> emit) {
    final ready = _ready;
    if (ready == null) return;
    _emitSuccess(emit,
        ready.copyWith(openPlayHarupBahar: !ready.openPlayHarupBahar));
  }

  void _onRemoveOpenPlayBet(
      RemoveOpenPlayBetEvent event, Emitter<GaliDesawarGameState> emit) {
    final ready = _ready;
    if (ready == null) return;
    final updated = List<GaliDesawarBet>.from(ready.openPlayBets)
      ..removeAt(event.index);
    _emitSuccess(emit, ready.copyWith(openPlayBets: updated));
  }

  // ── Jantri ────────────────────────────────────────────────────────────────────

  void _onUpdateJantriBet(
      UpdateJantriBetEvent event, Emitter<GaliDesawarGameState> emit) {
    final ready = _ready;
    if (ready == null) return;

    final amount = int.tryParse(event.amountText.trim()) ?? 0;
    final bets = List<GaliDesawarBet>.from(ready.jantriBets);

    // Remove existing entry for this number+type if present
    bets.removeWhere((b) =>
        b.betNumber == event.betNumber && b.betType == event.betType);

    // Re-add only if amount > 0
    if (amount > 0) {
      bets.add(GaliDesawarBet(
          betNumber: event.betNumber,
          betAmount: amount,
          betType: event.betType));
    }

    _emitSuccess(emit, ready.copyWith(jantriBets: bets));
  }

  // ── Cross Game ────────────────────────────────────────────────────────────────

  void _onRecalculateCross(
      RecalculateCrossGameEvent event, Emitter<GaliDesawarGameState> emit) {
    final ready = _ready;
    if (ready == null) return;

    final amount = int.tryParse(event.amountText.trim()) ?? 0;
    // Deduplicate digits
    final digits =
        event.digitsText.split('').toSet().toList();

    if (digits.isEmpty || amount <= 0) {
      _emitSuccess(emit, ready.copyWith(crossBets: []));
      return;
    }

    final bets = <GaliDesawarBet>[];
    for (final a in digits) {
      for (final b in digits) {
        if (a == b && ready.crossWithoutJoda) continue;
        bets.add(GaliDesawarBet(
            betNumber: a + b, betAmount: amount, betType: BetType.jodi));
      }
    }

    _emitSuccess(emit, ready.copyWith(crossBets: bets));
  }

  void _onToggleCrossWithoutJoda(ToggleCrossWithoutJodaEvent event,
      Emitter<GaliDesawarGameState> emit) {
    final ready = _ready;
    if (ready == null) return;
    _emitSuccess(
        emit, ready.copyWith(crossWithoutJoda: !ready.crossWithoutJoda));
  }

  void _onRemoveCrossBet(
      RemoveCrossBetEvent event, Emitter<GaliDesawarGameState> emit) {
    final ready = _ready;
    if (ready == null) return;
    final updated = List<GaliDesawarBet>.from(ready.crossBets)
      ..removeAt(event.index);
    _emitSuccess(emit, ready.copyWith(crossBets: updated));
  }

  // ── Submit ────────────────────────────────────────────────────────────────────

  Future<void> _onSubmit(SubmitGaliDesawarBetsEvent event,
      Emitter<GaliDesawarGameState> emit) async {
    final ready = _ready;
    if (ready == null) return;

    if (ready.activeBets.isEmpty) {
      _emitFeedback(
        emit,
        const GaliDesawarFeedback(
            type: GaliFeedbackType.error,
            message: 'Add at least one bet before submitting'),
        ready,
      );
      return;
    }

    if (ready.totalAmount > ready.walletBalance) {
      _emitFeedback(
        emit,
        GaliDesawarFeedback(
            type: GaliFeedbackType.error,
            message:
                'Insufficient balance. Need ₹${ready.totalAmount}, available ₹${ready.walletBalance}'),
        ready,
      );
      return;
    }

    emit(state.copyWith(
        gameState: LocalState.success(ready.copyWith(isSubmitting: true))));

    final payload = _buildPayload(ready);

    try {
      final result = await bettingUseCases.submitBetUseCase.call(payload);

      result.fold(
        (success) {
          // Clear the active mode's cart
          final cleared = _clearActiveBets(ready);
          emit(state.copyWith(
            gameState: LocalState.success(cleared),
            feedback: GaliDesawarFeedback(
                type: GaliFeedbackType.success,
                message: '${ready.activeBets.length} bet(s) placed!'),
          ));
          emit(state.copyWith(
              gameState: LocalState.success(cleared), feedback: null));

          // Refresh wallet
          _authBloc.add(FetchProfileEvent());
        },
        (error) {
          final recovered = ready.copyWith(isSubmitting: false);
          _emitFeedback(
            emit,
            GaliDesawarFeedback(
                type: GaliFeedbackType.error,
                message: error.message ?? 'Submit failed'),
            recovered,
          );
        },
      );
    } catch (e) {
      final recovered = ready.copyWith(isSubmitting: false);
      _emitFeedback(
        emit,
        GaliDesawarFeedback(
            type: GaliFeedbackType.error, message: e.toString()),
        recovered,
      );
    }
  }

  // ── Wallet sync ───────────────────────────────────────────────────────────────

  void _onSyncWallet(
      _SyncGaliWalletEvent event, Emitter<GaliDesawarGameState> emit) {
    final ready = _ready;
    if (ready == null || ready.walletBalance == event.wallet) return;
    _emitSuccess(emit, ready.copyWith(walletBalance: event.wallet));
  }

  // ── Private helpers ───────────────────────────────────────────────────────────

  List<String> _splitPairs(String s) {
    final result = <String>[];
    for (int i = 0; i + 1 < s.length; i += 2) {
      result.add(s.substring(i, i + 2));
    }
    return result;
  }

  List<Map<String, dynamic>> _buildPayload(GaliDesawarReadyData ready) {
    final payload = <Map<String, dynamic>>[];
    for (final bet in ready.activeBets) {
      final Map<String, dynamic> entry = {
        'user_id': SessionManager.instance.getUserId,
        'tag': ready.tag,
        'points': bet.betAmount,
        'market_id': ready.market.id,
        'session' : 'close'
      };
      switch (bet.betType) {
        case BetType.jodi:
          entry['open_digit'] = bet.betNumber[0];
          entry['close_digit'] = bet.betNumber[1];
          entry['game_mode'] = 'jodi-digit';
        case BetType.leftDigit:
          entry['open_digit'] = bet.betNumber;
          entry['game_mode'] = 'left-digit';
        case BetType.rightDigit:
          entry['close_digit'] = bet.betNumber;
          entry['game_mode'] = 'right-digit';
      }
      payload.add(entry);
    }
    return payload;
  }

  GaliDesawarReadyData _clearActiveBets(GaliDesawarReadyData ready) {
    return switch (ready.activeMode) {
      GaliDesawarMode.openPlay => ready.copyWith(
          openPlayBets: [],
          isSubmitting: false,
        ),
      GaliDesawarMode.jantri => ready.copyWith(
          jantriBets: [],
          isSubmitting: false,
        ),
      GaliDesawarMode.cross => ready.copyWith(
          crossBets: [],
          isSubmitting: false,
        ),
    };
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
