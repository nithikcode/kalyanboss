import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalyanboss/features/gali_desawar/presentation/pages/cross_game_screen.dart';
import 'package:kalyanboss/features/gali_desawar/presentation/pages/jantri_screen.dart';
import 'package:kalyanboss/features/gali_desawar/presentation/pages/open_play_screen.dart';
import 'package:kalyanboss/features/game/domain/entity/market_entity.dart';
import 'package:kalyanboss/features/gali_desawar/presentation/bloc/gali_desawar_game_bloc.dart';
import 'package:kalyanboss/services/session_manager.dart';

class GaliMarketSelectedScreen extends StatefulWidget {
  final MarketEntity market;

  const GaliMarketSelectedScreen({super.key, required this.market});

  @override
  State<GaliMarketSelectedScreen> createState() =>
      _GaliMarketSelectedScreenState();
}

class _GaliMarketSelectedScreenState extends State<GaliMarketSelectedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<GaliDesawarGameBloc>().add(InitGaliDesawarGameEvent(
            market: widget.market,
            tag: widget.market.tag,
            userId: SessionManager.instance.getUserId ?? '',
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.market.name,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Live wallet chip from bloc
          BlocBuilder<GaliDesawarGameBloc, GaliDesawarGameState>(
            buildWhen: (p, c) => c.gameState != p.gameState,
            builder: (_, state) {
              final wallet =
                  state.gameState.dataOrNull?.walletBalance;
              if (wallet == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Chip(
                  avatar: Icon(Icons.account_balance_wallet,
                      size: 16, color: colorScheme.primary),
                  label: Text('₹$wallet'),
                  visualDensity: VisualDensity.compact,
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Market info chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: colorScheme.outline.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // _timeChip(context, 'Open', widget.market.openTime),
                    // Container(width: 1, height: 24, color: colorScheme.outline),
                    _timeChip(context, 'Close', widget.market.closeTime),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              Text(
                'SELECT GAME MODE',
                style: theme.textTheme.labelLarge?.copyWith(
                  letterSpacing: 1.5,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Game mode buttons grid
              Row(
                children: [
                  Expanded(
                    child: _GameModeCard(
                      icon: Icons.play_circle_outline,
                      title: 'OPEN\nPLAY',
                      onTap: () => _navigate(
                          context, GaliDesawarMode.openPlay),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _GameModeCard(
                      icon: Icons.grid_view_rounded,
                      title: 'JANTRI\nGAME',
                      onTap: () =>
                          _navigate(context, GaliDesawarMode.jantri),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _GameModeCard(
                icon: Icons.shuffle_rounded,
                title: 'CROSS GAME',
                onTap: () =>
                    _navigate(context, GaliDesawarMode.cross),
                wide: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timeChip(BuildContext context, String label, String time) {
    final theme = Theme.of(context);
    return Column(

      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(_formatTime(time),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _formatTime(String time) {
    try {
      final parts = time.split(':');
      int hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      hour = hour % 12;
      if (hour == 0) hour = 12;
      return '$hour:$minute $period';
    } catch (_) {
      return time;
    }
  }

  void _navigate(BuildContext context, GaliDesawarMode mode) {
    final gameBloc = context.read<GaliDesawarGameBloc>();

    gameBloc.add(SwitchGaliModeEvent(mode));

    final Widget screen = switch (mode) {
      GaliDesawarMode.openPlay => const OpenPlayScreen(),
      GaliDesawarMode.jantri => const JantriScreen(),
      GaliDesawarMode.cross => const CrossGameScreen(),
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: gameBloc,
          child: screen,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Game mode card widget
// ─────────────────────────────────────────────────────────────────────────────
class _GameModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool wide;

  const _GameModeCard({
    required this.icon,
    required this.title,
    required this.onTap,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: wide ? 72 : 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withOpacity(0.15),
              colorScheme.primary.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: colorScheme.primary.withOpacity(0.3)),
        ),
        child: wide
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: colorScheme.primary, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: colorScheme.primary, size: 28),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface,
                      letterSpacing: 1.5,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
