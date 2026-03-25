import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kalyanboss/features/betting/config/game_type_config.dart';
import 'package:kalyanboss/features/betting/presentation/bloc/unified_game_bloc.dart';
import 'package:kalyanboss/features/betting/presentation/bloc/unified_game_event.dart';
import 'package:kalyanboss/features/betting/presentation/bloc/unified_game_state.dart';
import 'package:kalyanboss/features/betting/presentation/widgets/bet_cart_widget.dart';
import 'package:kalyanboss/features/betting/presentation/widgets/input_strategy_widgets.dart';
import 'package:kalyanboss/features/game/domain/entity/game_mode_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Route arguments
// ─────────────────────────────────────────────────────────────────────────────
class BetScreenArgs {
  final GameModeEntity gameMode;
  final String marketId;
  final String userId;

  const BetScreenArgs({
    required this.gameMode,
    required this.marketId,
    required this.userId,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// UniversalBetScreen
// ─────────────────────────────────────────────────────────────────────────────
class UniversalBetScreen extends StatefulWidget {
  static const routeName = '/universal-bet';

  final BetScreenArgs args;

  const UniversalBetScreen({super.key, required this.args});

  @override
  State<UniversalBetScreen> createState() => _UniversalBetScreenState();
}

class _UniversalBetScreenState extends State<UniversalBetScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<UnifiedGameBloc>().add(InitGameEvent(
        gameMode: widget.args.gameMode,
        marketId: widget.args.marketId,
        userId: widget.args.userId,
      ));
    });
  }

  // ── Listener ────────────────────────────────────────────────────────────────

  void _handleStateChange(BuildContext ctx, UnifiedGameState state) {
    if (state is GameValidationErrorState) {
      _showSnack(ctx, state.message, isError: true);
    } else if (state is GameSubmitSuccessState) {
      _showSnack(ctx, state.message, isError: false);
      // Pop back to game list with a success signal so it can refresh.
      Future.microtask(() {
        if (mounted) ctx.pop(true);
      });
    } else if (state is GameSubmitFailureState) {
      _showSnack(ctx, state.message, isError: true);
    }
  }

  void _showSnack(BuildContext ctx, String msg, {required bool isError}) {
    ScaffoldMessenger.of(ctx)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor:
          isError ? Colors.red.shade700 : Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<UnifiedGameBloc, UnifiedGameState>(
      // Only listen to transient notification states — never to GameReadyState
      // or GameLoadingState, which are handled by the BlocBuilder below.
      listenWhen: (_, curr) =>
      curr is GameValidationErrorState ||
          curr is GameSubmitSuccessState ||
          curr is GameSubmitFailureState,
      listener: _handleStateChange,
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: BlocBuilder<UnifiedGameBloc, UnifiedGameState>(
          // ─────────────────────────────────────────────────────────────────
          // KEY FIX: Only rebuild the body for persistent UI states.
          // Transient states (validation errors, submit success/failure) are
          // handled entirely by the BlocListener above and must NOT cause a
          // rebuild here — otherwise the UI can blank out momentarily.
          // ─────────────────────────────────────────────────────────────────
          buildWhen: (previous, current) =>
          current is GameLoadingState ||
              current is GameReadyState ||
              current is GameErrorState,
          builder: (ctx, state) {
            if (state is GameLoadingState) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is GameErrorState) {
              return _ErrorView(
                message: state.message,
                onRetry: () =>
                    ctx.read<UnifiedGameBloc>().add(InitGameEvent(
                      gameMode: widget.args.gameMode,
                      marketId: widget.args.marketId,
                      userId: widget.args.userId,
                    )),
              );
            }

            if (state is GameReadyState) {
              return _ReadyBody(state: state);
            }

            // Fallback — should never be reached with the buildWhen above.
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: BlocBuilder<UnifiedGameBloc, UnifiedGameState>(
        buildWhen: (_, curr) =>
        curr is GameReadyState || curr is GameLoadingState,
        builder: (_, state) {
          final name = state is GameReadyState
              ? state.gameMode.name
              : widget.args.gameMode.name;
          return Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          );
        },
      ),
      actions: [
        BlocBuilder<UnifiedGameBloc, UnifiedGameState>(
          buildWhen: (_, curr) => curr is GameReadyState,
          builder: (_, state) {
            if (state is! GameReadyState) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Chip(
                avatar: const Icon(Icons.account_balance_wallet, size: 16),
                label: Text('₹${state.settings.walletBalance}'),
                visualDensity: VisualDensity.compact,
              ),
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ready body
// ─────────────────────────────────────────────────────────────────────────────
class _ReadyBody extends StatelessWidget {
  final GameReadyState state;

  const _ReadyBody({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Session toggle (hidden for open-only games)
                _SessionSelector(
                  config: state.config,
                  current: state.currentSession,
                ),
                const SizedBox(height: 16),

                // Hint banner
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceVariant
                        .withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.config.hint,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Input widget chosen by game type
                _InputStrategySwitch(style: state.config.inputStyle),
                const SizedBox(height: 24),

                // Cart header
                Text(
                  'Cart',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const BetCartWidget(),
              ],
            ),
          ),
        ),

        // Sticky submit button
        _SubmitBar(state: state),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Session selector
// ─────────────────────────────────────────────────────────────────────────────
class _SessionSelector extends StatelessWidget {
  final GameTypeConfig config;
  final String current;

  const _SessionSelector({required this.config, required this.current});

  @override
  Widget build(BuildContext context) {
    if (config.sessionType == SessionType.open) {
      return const SizedBox.shrink();
    }
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(
            value: 'OPEN',
            label: Text('Open'),
            icon: Icon(Icons.lock_open)),
        ButtonSegment(
            value: 'CLOSE',
            label: Text('Close'),
            icon: Icon(Icons.lock)),
      ],
      selected: {current},
      onSelectionChanged: (s) =>
          context.read<UnifiedGameBloc>().add(UpdateSessionEvent(s.first)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Strategy switch — routes to the correct input widget
// ─────────────────────────────────────────────────────────────────────────────
class _InputStrategySwitch extends StatelessWidget {
  final InputStyle style;

  const _InputStrategySwitch({required this.style});

  @override
  Widget build(BuildContext context) {
    return switch (style) {
      InputStyle.gridStyle => const GridStyleInput(),
      InputStyle.inputStyle => const InputStyleInput(),
      InputStyle.bulkStyle => const BulkStyleInput(),
      InputStyle.motorStyle => const MotorStyleInput(),
      InputStyle.sangamStyle => const SangamStyleInput(),
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Submit bar (sticky bottom)
// ─────────────────────────────────────────────────────────────────────────────
class _SubmitBar extends StatelessWidget {
  final GameReadyState state;

  const _SubmitBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final isSubmitting = state.isSubmitting;
    final canSubmit = state.canSubmit && !isSubmitting;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: canSubmit
                ? () => context
                .read<UnifiedGameBloc>()
                .add(const SubmitBetsEvent())
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isSubmitting
                ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
                : Text(
              state.cart.isEmpty
                  ? 'Add bets to submit'
                  : 'Submit ${state.cart.length} '
                  'Bet${state.cart.length > 1 ? 's' : ''}'
                  ' · ₹${state.totalPoints}',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error view
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}