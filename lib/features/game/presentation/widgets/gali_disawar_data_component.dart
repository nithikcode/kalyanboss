import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:kalyanboss/config/routes/route_names.dart';
import 'package:kalyanboss/features/auth/domain/entities/user_entity.dart';
import 'package:kalyanboss/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kalyanboss/features/game/domain/entity/market_entity.dart';
import 'package:kalyanboss/features/game/presentation/bloc/game_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class GaliDesawarDataComponent extends StatelessWidget {
  const GaliDesawarDataComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc bloc) {
      return bloc.state.userEntity?.whenOrNull(
        success: (data) => data,
      );
    });
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        // Accessing your specific GaliDesawar Entity from the state
        final marketState = state.galiDesawarMarketResponseEntity;

        if (marketState == null) return const SizedBox.shrink();

        return marketState.when(
          initial: () => const Center(child: CircularProgressIndicator()),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (message, _) => _buildError(message, context),
          refreshing: (data) => _buildMarketList(context, data?.data ?? [], state, user),
          success: (entity) => RefreshIndicator(
            onRefresh: () async {
              context.read<GameBloc>().add(FetchGaliDesawarMarkets());
              context.read<AuthBloc>().add(FetchProfileEvent());
            },
            child: _buildMarketList(context, entity.data, state,user),
          ),
        );
      },
    );
  }

  Widget _buildMarketList(BuildContext context, List<MarketEntity> markets, GameState state, UserEntity? user) {
    // Filtering active markets
    final activeMarkets = markets.where((e) => e.status == true).toList();

    if (activeMarkets.isEmpty) {
      return const Center(child: Text("No Active Markets Found"));
    }

    return ListView.builder(
      itemCount: activeMarkets.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final game = activeMarkets[index];
        return _buildMarketCard(context, game, state,user);
      },
    );
  }

  Widget _buildMarketCard(BuildContext context, MarketEntity game, GameState state, UserEntity? user) {
    final bool isClosed = game.marketStatus == false || _isTimePassed(game.closeTime);

    return Column(
      children: [
        InkWell(
          onTap: () => _handleOnTap(context, game, user),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Chart Icon
                    _buildChartIcon(game.id),

                    // Game Info
                    Column(
                      children: [
                        Text(game.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          "${game.openDigit == "-" ? 'X' : game.openDigit}-${game.closeDigit == "-" ? 'X' : game.closeDigit}",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                        ),
                        Text(
                          'Close: ${_formatTime(game.closeTime)}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),

                    // Play/Pause Icon
                    Image.asset(
                      isClosed ? "assets/images/pause.png" : "assets/images/play.png",
                      width: 35,
                      height: 35,
                    )
                  ],
                ),
                const Divider(height: 24),
                Text(
                  isClosed ? "MARKET IS CLOSED" : "MARKET IS OPEN",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isClosed ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // --- Logic Helpers ---

  void _handleOnTap(BuildContext context, MarketEntity game, dynamic user) {
    // Vibration.vibrate(duration: 100);
    HapticFeedback.selectionClick();

    if (game.marketStatus == false) {
      _showToast(context, 'Holiday!!! Market is closed.');
      return;
    }

    if (_isTimePassed(game.closeTime)) {
      _showToast(context, 'Market is closed for the day.');
      return;
    }

    // Check user permissions (betting status)
    if (user?.betting == false || user?.status == false) {
      _showToast(context, 'Please contact admin to enable betting.');
      return;
    }

    context.pushNamed(RouteNames.galiDisawarMarketScreen, extra: {
      'market' : game
    });
  }

  Widget _buildChartIcon(String marketId) {
    return InkWell(
      onTap: () {
        final url = "https://yourwebsite.com/gali-chart.html?market=$marketId";
        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      },
      child: Image.asset("assets/images/chart.png", width: 50, height: 50),
    );
  }

  bool _isTimePassed(String time) {
    // Implement your time comparison logic here
    // Example: return DateTime.now().isAfter(parsedCloseTime);
    return false; // Placeholder
  }

  String _formatTime(String time) {
    // Convert 24hr to 12hr logic
    return time;
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildError(String message, BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(message, style: const TextStyle(color: Colors.red)),
          TextButton(
            onPressed: () => context.read<GameBloc>().add(FetchGaliDesawarMarkets()),
            child: const Text("Retry"),
          )
        ],
      ),
    );
  }
}