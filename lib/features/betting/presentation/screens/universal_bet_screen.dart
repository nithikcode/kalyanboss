import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kalyanboss/config/constants.dart';
import 'package:kalyanboss/features/betting/config/game_type_config.dart';
import 'package:kalyanboss/features/betting/presentation/bloc/unified_game_bloc.dart';
import 'package:kalyanboss/features/betting/presentation/bloc/unified_game_event.dart';
import 'package:kalyanboss/features/betting/presentation/bloc/unified_game_state.dart';
import 'package:kalyanboss/features/betting/presentation/widgets/bet_cart_widget.dart';
import 'package:kalyanboss/features/betting/presentation/widgets/input_strategy_widgets.dart';
import 'package:kalyanboss/features/game/domain/entity/game_mode_entity.dart';
import 'package:kalyanboss/features/game/domain/entity/market_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Route arguments
// ─────────────────────────────────────────────────────────────────────────────
class BetScreenArgs {
  final GameModeEntity gameMode;
  final MarketEntity market;
  final String userId;

  const BetScreenArgs({
    required this.gameMode,
    required this.market,
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
        market: widget.args.market,
        userId: widget.args.userId,
      ));
    });
  }

  // ── Listener ─────────────────────────────────────────────────────────────────

  void _handleStateChange(BuildContext ctx, UnifiedGameState state) {
    final feedback = state.feedback;
    if (feedback == null) return;

    _showSnack(ctx, feedback.message, isError: feedback.isError);

    if (feedback.type == FeedbackType.submitSuccess) {
      Future.microtask(() {
        if (mounted) ctx.pop(true);
      });
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

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<UnifiedGameBloc, UnifiedGameState>(
      // Only fire the listener when a non-null feedback object arrives.
      listenWhen: (previous, current) =>
      current.feedback != null && current.feedback != previous.feedback,
      listener: _handleStateChange,
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: BlocBuilder<UnifiedGameBloc, UnifiedGameState>(
          // Rebuild the body only when the gameState changes — the [feedback]
          // field is handled exclusively by the listener above so it never
          // causes a body rebuild / blank-out.
          buildWhen: (previous, current) =>
          current.gameState != previous.gameState,
          builder: (ctx, state) {
            return state.gameState.when(
              initial: () =>
              const Center(child: CircularProgressIndicator()),
              loading: () =>
              const Center(child: CircularProgressIndicator()),
              refreshing: (_) =>
              const Center(child: CircularProgressIndicator()),
              success: (data) => _ReadyBody(data: data),
              error: (message, _) => _ErrorView(
                message: message,
                onRetry: () => ctx.read<UnifiedGameBloc>().add(InitGameEvent(
                  gameMode: widget.args.gameMode,
                  market: widget.args.market,
                  userId: widget.args.userId,
                )),
              ),
            );
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: BlocBuilder<UnifiedGameBloc, UnifiedGameState>(
        buildWhen: (previous, current) =>
        current.gameState != previous.gameState,
        builder: (_, state) {
          final name = state.gameState.whenOrNull(success: (d) => d.gameMode.name)
              ?? widget.args.gameMode.name;
          return Text(name, style: const TextStyle(fontWeight: FontWeight.bold));
        },
      ),
      actions: [
        BlocBuilder<UnifiedGameBloc, UnifiedGameState>(
          buildWhen: (previous, current) =>
          current.gameState != previous.gameState,
          builder: (_, state) {
            final data = state.gameState.dataOrNull;
            if (data == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Chip(
                avatar: SvgPicture.asset(AppLogos.wallet),
                label: Text('₹${data.settings.walletBalance}'),
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
  final GameReadyData data;

  const _ReadyBody({required this.data});

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
                  config: data.config,
                  current: data.currentSession,
                  isOpenLocked: data.isOpenLocked,
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
                          data.config.hint,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Input widget chosen by game type
                _InputStrategySwitch(style: data.config.inputStyle),
                const SizedBox(height: 24),


                const BetCartWidget(),
              ],
            ),
          ),
        ),

        // Sticky submit button
        _SubmitBar(data: data),
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
  final bool isOpenLocked;

  const _SessionSelector({
    required this.config,
    required this.current,
    required this.isOpenLocked,
  });

  @override
  Widget build(BuildContext context) {
    if (config.sessionType == SessionType.open) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<String>(
          segments: [
            ButtonSegment(
              value: 'OPEN',
              label: Text(isOpenLocked ? 'Open (closed)' : 'Open'),
              icon: SvgPicture.asset(isOpenLocked ? AppLogos.lock : AppLogos.unlock),
              enabled: !isOpenLocked,
            ),
            ButtonSegment(
              value: 'CLOSE',
              label: const Text('Close'),
              icon: SvgPicture.asset( AppLogos.lock),
            ),
          ],
          selected: {current},
          onSelectionChanged: (s) =>
              context.read<UnifiedGameBloc>().add(UpdateSessionEvent(s.first)),
        ),
        if (isOpenLocked) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.info_outline,
                  size: 14,
                  color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 6),
              Text(
                'Open session has closed for this market.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ],
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
  final GameReadyData data;

  const _SubmitBar({required this.data});

  @override
  Widget build(BuildContext context) {
    final canSubmit = data.canSubmit && !data.isSubmitting;

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
            child: data.isSubmitting
                ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
                : Text(
              data.cart.isEmpty
                  ? 'Add bets to submit'
                  : 'Submit ${data.cart.length} '
                  'Bet${data.cart.length > 1 ? 's' : ''}'
                  ' · ₹${data.totalPoints}',
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