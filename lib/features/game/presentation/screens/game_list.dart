import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kalyanboss/config/routes/route_names.dart';
import 'package:kalyanboss/config/theme/theme.dart';
import 'package:kalyanboss/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kalyanboss/features/game/domain/entity/game_mode_entity.dart';
import 'package:kalyanboss/features/game/domain/entity/market_entity.dart';
import 'package:kalyanboss/features/game/presentation/bloc/game_bloc.dart';
import 'package:kalyanboss/services/session_manager.dart';
import 'package:kalyanboss/utils/helpers/helpers.dart';

class GameList extends StatefulWidget {
  final MarketEntity market;


  const GameList({
    super.key,
    required this.market,
  });

  @override
  State<GameList> createState() => _GameListState();
}

class _GameListState extends State<GameList>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    context.read<GameBloc>().add(FetchGameModes());

    _bgController =
    AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          ///  Animated Background (theme-based)
          AnimatedBuilder(
            animation: _bgController,
            builder: (_, __) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.lerp(
                        colors.primary.withOpacity(0.15),
                        colors.secondary.withOpacity(0.15),
                        _bgController.value,
                      )!,
                      theme.scaffoldBackgroundColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              );
            },
          ),

          /// MAIN UI
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios,
                    color: colors.onBackground, size: 18),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                widget.market.name.toUpperCase(),
                style: AppTextStyles.h3(color: colors.onBackground),
              ),
              actions: [_buildWalletAction(context)],
            ),
            body: BlocBuilder<GameBloc, GameState>(
              builder: (context, state) {
                return state.gameModesEntity!.when(
                  initial: () => const SizedBox.shrink(),
                  loading: () => _buildShimmer(),
                  refreshing: (oldData) =>
                      _buildContent(oldData?.data ?? []),
                  error: (msg, _) =>
                      _buildErrorState(msg, colors),
                  success: (response) =>
                      _buildContent(response.data),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================= CONTENT =================

  Widget _buildContent(List<GameModeEntity> games) {
    final Map<String, List<GameModeEntity>> grouped = {};
    for (var g in games) {
      if (g.status) {
        grouped.putIfAbsent(g.category, () => []).add(g);
      }
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildHeader(),
          ...grouped.entries.map(
                (e) => _buildCategory(e.key, e.value),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCategory(String title, List<GameModeEntity> games) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _section(title),
        GridView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.82,
          ),
          itemCount: games.length,
          itemBuilder: (context, index) {
            final game = games[index];

            return TweenAnimationBuilder(
              duration: Duration(milliseconds: 400 + index * 60),
              tween: Tween(begin: 0.8, end: 1.0),
              builder: (_, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: _gameCard(game, index),
            );
          },
        ),
      ],
    );
  }

  // ================= CARD =================

  Widget _gameCard(GameModeEntity game, int index) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return GestureDetector(
      onTap: () => _handleNavigation(game),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),

          /// surface color from theme
          color: colors.surface.withOpacity(0.6),

          /// subtle border
          border: Border.all(color: colors.outline.withOpacity(0.2)),

          /// shadow
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withOpacity(0.3),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 80,
                width: 80,
                child: CachedNetworkImage(
                  imageUrl: game.image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),

            Text(
              game.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "Tap to Play",
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================

  Widget _buildHeader() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "🎮 Game Lobby",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.onBackground,
            ),
          ),

        ],
      ),
    );
  }

  Widget _section(String title) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // ================= WALLET =================
  Widget _buildWalletAction(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // 1. Get the current AuthState
    final authState = context.watch<AuthBloc>().state;

    // 2. Extract the wallet balance safely
    // We use ?.success to see if the ApiState is in success mode,
    // or simply drill into .userEntity?.data?.wallet
    final walletBalance = authState.userEntity?.whenOrNull(success: (data) => data.wallet);

    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary, colors.secondary],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.account_balance_wallet,
              color: colors.onPrimary, size: 16),
          const SizedBox(width: 6),
          Text(
            '₹$walletBalance', // Updated line
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ================= SHIMMER =================

  Widget _buildShimmer() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
      ),
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              colors.surface.withOpacity(0.3),
              colors.surface.withOpacity(0.6),
              colors.surface.withOpacity(0.3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message, ColorScheme colors) {
    return Center(
      child: Text(
        message,
        style: TextStyle(color: colors.error),
      ),
    );
  }

  void _handleNavigation(GameModeEntity game) async {
    final name = game.name.toLowerCase();

    // These games MUST be blocked if OPEN TIME has passed
    bool isRestricted = name.contains('jodi') ||
        name.contains('sangam') ||
        name.contains('bracket') ||
        name.contains('red');

    if (isRestricted) {
      // Pass 'openTime' specifically for these games
      if (_isTimePassed(widget.market.openTime)) {
        Fluttertoast.showToast(msg: 'Game is only available before open time.');
        return;
      }
    }

    createLog("Navigating to $game");

    // Regular navigation
    final result = await context.pushNamed(
      RouteNames.unifiedGameScreen,
      extra: {
        'gameMode': game,
        'marketId': widget.market.id,
        'userId': SessionManager.instance.getUserId,
      },
    );

    if (result == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  bool _isTimePassed(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return false;

    try {
      final DateTime deviceNow = DateTime.now();

      // Support both "10:30 AM" and "14:30" formats
      DateFormat inputFormat;
      if (timeStr.toUpperCase().contains('AM') || timeStr.toUpperCase().contains('PM')) {
        inputFormat = DateFormat("hh:mm a");
      } else {
        inputFormat = DateFormat("HH:mm");
      }

      final DateTime parsedTime = inputFormat.parse(timeStr.trim());

      // Create a DateTime object for TODAY with the market's time
      final DateTime targetTime = DateTime(
        deviceNow.year,
        deviceNow.month,
        deviceNow.day,
        parsedTime.hour,
        parsedTime.minute,
      );

      // If device time is GREATER than target time, it has passed.
      return deviceNow.isAfter(targetTime);
    } catch (e) {
      print("Time comparison error: $e");
      return false; // Default to open if we can't parse
    }
  }
}