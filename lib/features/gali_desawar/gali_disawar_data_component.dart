import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalyanboss/features/auth/domain/entities/user_entity.dart';
import 'package:kalyanboss/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kalyanboss/features/gali_desawar/presentation/pages/gali_market_selected_screen.dart';
import 'package:kalyanboss/features/game/domain/entity/market_entity.dart';
import 'package:kalyanboss/features/game/presentation/bloc/game_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class GaliDesawarDataComponent extends StatelessWidget {
  const GaliDesawarDataComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc bloc) {
      return bloc.state.userEntity?.whenOrNull(success: (data) => data);
    });

    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        final marketState = state.galiDesawarMarketResponseEntity;
        if (marketState == null) return const SizedBox.shrink();

        return marketState.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (message, _) => _buildError(message, context),
          refreshing: (data) =>
              _buildMarketList(context, data?.data ?? [], user),
          success: (entity) => _buildMarketList(context, entity.data, user),
        );
      },
    );
  }

  Widget _buildMarketList(
      BuildContext context, List<MarketEntity> markets, UserEntity? user) {
    final activeMarkets = markets.where((e) => e.status == true).toList();

    if (activeMarkets.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text('No active markets found',
              style: Theme.of(context).textTheme.bodyMedium),
        ),
      );
    }

    return ListView.builder(
      itemCount: activeMarkets.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) =>
          _buildMarketCard(context, activeMarkets[index], user),
    );
  }

  Widget _buildMarketCard(
      BuildContext context, MarketEntity game, UserEntity? user) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isClosed =
        game.marketStatus == false || _isTimePassed(game.closeTime);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _handleOnTap(context, game, user),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: colorScheme.outline.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Chart icon
                    _buildChartIcon(game.id),

                    // Game info
                    Column(
                      children: [
                        Text(
                          game.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${game.openDigit == "-" ? "X" : game.openDigit}'
                          ' - '
                          '${game.closeDigit == "-" ? "X" : game.closeDigit}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Close: ${_formatTime(game.closeTime)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),

                    // Play / Pause icon
                    Image.asset(
                      isClosed
                          ? 'assets/images/pause.png'
                          : 'assets/images/play.png',
                      width: 34,
                      height: 34,
                    ),
                  ],
                ),
                Divider(
                    height: 24,
                    color: colorScheme.outline.withOpacity(0.2)),
                Text(
                  isClosed ? 'MARKET IS CLOSED' : 'MARKET IS OPEN',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isClosed ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  void _handleOnTap(
      BuildContext context, MarketEntity game, UserEntity? user) {
    HapticFeedback.selectionClick();

    if (game.marketStatus == false) {
      _showSnack(context, 'Holiday! Market is closed.');
      return;
    }

    if (_isTimePassed(game.closeTime)) {
      _showSnack(context, 'Market is closed for the day.');
      return;
    }

    if (user?.betting == false || user?.status == false) {
      _showSnack(context, 'Please contact admin to enable betting.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GaliMarketSelectedScreen(market: game),
      ),
    );
  }

  /// Returns true when the given "HH:mm" time string is in the past today.
  bool _isTimePassed(String time) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final now = TimeOfDay.now();
      return now.hour > hour ||
          (now.hour == hour && now.minute >= minute);
    } catch (_) {
      return false;
    }
  }

  /// Converts "HH:mm" → "H:mm AM/PM".
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

  Widget _buildChartIcon(String marketId) {
    return InkWell(
      onTap: () {
        final url =
            'https://yourwebsite.com/gali-chart.html?market=$marketId';
        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      },
      child: Image.asset('assets/images/chart.png', width: 50, height: 50),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ));
  }

  Widget _buildError(String message, BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () =>
                  context.read<GameBloc>().add(FetchGaliDesawarMarkets()),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
