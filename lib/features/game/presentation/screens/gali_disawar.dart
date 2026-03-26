import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kalyanboss/config/constants.dart';
import 'package:kalyanboss/config/routes/route_names.dart';
import 'package:kalyanboss/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kalyanboss/features/game/presentation/bloc/game_bloc.dart';
import 'package:kalyanboss/features/game/presentation/widgets/gali_disawar_data_component.dart';


class GaliDesawarScreen extends StatefulWidget {
  const GaliDesawarScreen({super.key});

  @override
  State<GaliDesawarScreen> createState() => GaliDesawarScreenState();
}

class GaliDesawarScreenState extends State<GaliDesawarScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late AnimationController _depositAnimationController;
  late Animation<double> _depositGlowAnimation;
  late Animation<double> _depositBounceAnimation;
  late Animation<double> _depositIconScaleAnimation;

  @override
  void initState() {
    super.initState();
    context.read<GameBloc>().add(FetchGaliDesawarMarkets());
    context.read<AuthBloc>().add(FetchProfileEvent());
    _initAnimations();
  }

  void _initAnimations() {
    _depositAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _depositGlowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _depositAnimationController, curve: Curves.easeInOut),
    );

    _depositBounceAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _depositAnimationController, curve: Curves.bounceInOut),
    );

    _depositIconScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _depositAnimationController, curve: Curves.elasticInOut),
    );
  }

  @override
  void dispose() {
    _depositAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.surface, colorScheme.surface.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: false,
        title: Text(
          'Gali Desawar',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final user = state.userEntity?.maybeWhen(
                success: (u) => u,
                refreshing: (u) => u,
                orElse: () => null,
              );

              if (user == null || user.betting == false) return const SizedBox();

              return Row(
                children: [
                  SvgPicture.asset(
                      AppLogos.wallet,
                      height: 20,
                      colorFilter: ColorFilter.mode(colorScheme.primary, BlendMode.srcIn)
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '₹${user.wallet}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 12),

                ],
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.surface,
              colorScheme.surfaceVariant.withOpacity(0.5),
              colorScheme.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<GameBloc>().add(FetchGaliDesawarMarkets());
              context.read<AuthBloc>().add(FetchProfileEvent());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Wallet Section
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final user = state.userEntity?.maybeWhen(
                          success: (u) => u,
                          orElse: () => null,
                        );
                        if (user == null) return const SizedBox();

                        return Column(
                          children: [
                            _buildSectionHeader(context, 'Wallet Actions'),
                            Row(
                              children: [
                                Expanded(child: _buildDepositButton(context)),
                                const SizedBox(width: 12),
                                Expanded(child: _buildWithdrawButton(context)),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // History Section
                    _buildSectionHeader(context, 'History'),
                    Row(
                      children: [
                        Expanded(
                            child: _buildHistoryCard(
                                context,
                                'Bid History',
                                AppLogos.calendar,
                                    () =>
                                  context.pushNamed(RouteNames.galiDisawarHistoryScreen)
                                     // Navigation
                            )
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildHistoryCard(
                                context,
                                'Win History',
                                AppLogos.transaction,
                                    () => {} // Navigation
                            )
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Markets
                    const GaliDesawarDataComponent(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- UI Components using Theme ---

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepositButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _depositAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _depositBounceAnimation.value,
          child: InkWell(
            onTap: () => HapticFeedback.mediumImpact(),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withRed(200), // Dynamic blend
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3 * _depositGlowAnimation.value),
                    blurRadius: 15,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale: _depositIconScaleAnimation.value,
                      child: Icon(Icons.add_circle_outline, color: colorScheme.onPrimary)),
                  const SizedBox(width: 8),
                  Text(
                    'DEPOSIT',
                    style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWithdrawButton(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet_outlined, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            const Text('WITHDRAW', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, String title, String asset, VoidCallback onTap) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            SvgPicture.asset(
                asset,
                height: 24,
                colorFilter: ColorFilter.mode(theme.colorScheme.primary, BlendMode.srcIn)
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}