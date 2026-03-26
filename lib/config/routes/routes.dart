import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kalyanboss/config/routes/route_names.dart';
import 'package:kalyanboss/features/auth/presentation/pages/login_page.dart';
import 'package:kalyanboss/features/auth/presentation/pages/verify_otp_screen.dart';
import 'package:kalyanboss/features/base/presentation/bloc/base_bloc.dart';
import 'package:kalyanboss/features/base/presentation/pages/base_screen.dart';
import 'package:kalyanboss/features/betting/presentation/bloc/unified_game_bloc.dart';
import 'package:kalyanboss/features/betting/presentation/screens/universal_bet_screen.dart';
import 'package:kalyanboss/features/gali_desawar/presentation/bloc/gali_desawar_game_bloc.dart';
import 'package:kalyanboss/features/gali_desawar/presentation/pages/gali_market_selected_screen.dart';
import 'package:kalyanboss/features/game/domain/entity/market_entity.dart';
import 'package:kalyanboss/features/game/presentation/bloc/game_bloc.dart';
import 'package:kalyanboss/features/game/presentation/screens/bet_history_screen.dart';
import 'package:kalyanboss/features/game/presentation/screens/chart_screen.dart';
import 'package:kalyanboss/features/game/presentation/screens/gali_disawar.dart';
import 'package:kalyanboss/features/game/presentation/screens/gali_disawar_bet_history_screen.dart';
import 'package:kalyanboss/features/game/presentation/screens/game_list_screen.dart';
import 'package:kalyanboss/features/game/presentation/screens/game_screen.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/base/presentation/pages/splash_screen.dart';
import '../../utils/di/service_locator.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
class AppRouter {
  static GoRouter get router => _router;

  // Helper method to wrap routes with a consistent transition
  static Page<dynamic> _withTransition(GoRouterState state, Widget child) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    );
  }

  static final GoRouter _router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: GoRouterRefreshStream(
      sl<AuthBloc>().stream.where(
            (state) => state.isAuthenticated != sl<AuthBloc>().state.isAuthenticated,
      ),
    ),
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: RouteNames.splash,
        pageBuilder: (context, state) => _withTransition(state, const SplashScreen()),
      ),
      GoRoute(
        path: RouteNames.register,
        name: RouteNames.register,
        pageBuilder: (context, state) => _withTransition(state, const RegisterPage()),
      ),
      GoRoute(
        path: RouteNames.loginScreen,
        name: RouteNames.loginScreen,
        pageBuilder: (context, state) => _withTransition(state, const LoginScreen()),
      ),
      GoRoute(
        path: RouteNames.verifyOtp,
        name: RouteNames.verifyOtp,
        pageBuilder: (context, state) => _withTransition(state, const VerifyOtpScreen()),
      ),
      GoRoute(
        path: RouteNames.gameScreen,
        name: RouteNames.gameScreen,
        pageBuilder: (context, state) => _withTransition(state, const GameScreen()),
      ),
      GoRoute(
        path: RouteNames.gameList,
        name: RouteNames.gameList,
        pageBuilder: (context, state) {
          // 1. Extract arguments safely from state.extra
          final args = state.extra as Map<String, dynamic>? ?? {};

          // 2. Wrap the screen with BlocProvider using Service Locator (sl)
          return _withTransition(
            state,
            BlocProvider<GameBloc>(
              // sl<GameBloc>() automatically handles UseCases & SessionManager injection
              create: (context) => sl<GameBloc>(),
              child: GameList(
                market: args['market'],
              ),
            ),
          );
        },
      ),

      GoRoute(
        path: RouteNames.chartScreen,
        name: RouteNames.chartScreen,
        pageBuilder: (context, state) {
          // 1. Extract arguments safely from state.extra
          final args = state.extra as Map<String, dynamic>? ?? {};

          final marketId = args['marketId'];
          final marketName = args['marketName'];
          // 2. Wrap the screen with BlocProvider using Service Locator (sl)
          return _withTransition(
            state,
            BlocProvider<GameBloc>(
              // sl<GameBloc>() automatically handles UseCases & SessionManager injection
              create: (context) => sl<GameBloc>(),
              child: ChartScreen(
                marketId: marketId,
                marketName: marketName,
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: RouteNames.betHistoryScreen,
        name: RouteNames.betHistoryScreen,
        pageBuilder: (context, state) {
          // 2. Wrap the screen with BlocProvider using Service Locator (sl)
          return _withTransition(
            state,
            BlocProvider<GameBloc>(
              // sl<GameBloc>() automatically handles UseCases & SessionManager injection
              create: (context) => sl<GameBloc>(),
              child: BetHistoryScreen(),
            ),
          );
        },
      ),
      GoRoute(
        path: RouteNames.galiDisawarScreen,
        name: RouteNames.galiDisawarScreen,
        pageBuilder: (context, state) {
          // 2. Wrap the screen with BlocProvider using Service Locator (sl)
          return _withTransition(
            state,
            BlocProvider<GameBloc>(
              // sl<GameBloc>() automatically handles UseCases & SessionManager injection
              create: (context) => sl<GameBloc>(),
              child: GaliDesawarScreen(),
            ),
          );
        },
      ),
      GoRoute(
        path: RouteNames.galiDisawarHistoryScreen,
        name: RouteNames.galiDisawarHistoryScreen,
        pageBuilder: (context, state) {
          // 2. Wrap the screen with BlocProvider using Service Locator (sl)
          return _withTransition(
            state,
            BlocProvider<GameBloc>(
              // sl<GameBloc>() automatically handles UseCases & SessionManager injection
              create: (context) => sl<GameBloc>(),
              child: GaliDisawarBetHistoryScreen(),
            ),
          );
        },
      ),
      GoRoute(
        path: RouteNames.galiDisawarMarketScreen,
        name: RouteNames.galiDisawarMarketScreen,
        // ✅ Guard: if extras are lost (GoRouter refresh dropped them), go back
        redirect: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          if (args == null || args['market'] == null) {
            return RouteNames.galiDisawarScreen; // or RouteNames.home
          }
          return null;
        },
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          final data = args['market'] as MarketEntity; // safe — redirect guards this

          return _withTransition(
            state,
            BlocProvider<GaliDesawarGameBloc>(
              create: (context) => sl<GaliDesawarGameBloc>(),
              child: GaliMarketSelectedScreen(market: data),
            ),
          );
        },
      ),
      GoRoute(
        path: RouteNames.unifiedGameScreen,
        name: RouteNames.unifiedGameScreen,
        pageBuilder: (context, state) {
          // 1. Extract arguments safely from state.extra
          final args = state.extra as Map<String, dynamic>? ?? {};

          final betArgs = BetScreenArgs(gameMode: args['gameMode'], market: args['market'], userId: args['userId']);
          // 2. Wrap the screen with BlocProvider using Service Locator (sl)
          return _withTransition(
            state,
            BlocProvider<UnifiedGameBloc>(
              // sl<GameBloc>() automatically handles UseCases & SessionManager injection
              create: (context) => sl<UnifiedGameBloc>(),
              child: UniversalBetScreen(args: betArgs,),
            ),
          );
        },
      ),

      GoRoute(
        path: RouteNames.home,
        name: RouteNames.home,
        pageBuilder: (context, state) => _withTransition(
          state,
          MultiBlocProvider(
            providers: [
              // Provides tab switching logic
              BlocProvider<BaseBloc>(
                create: (context) => sl<BaseBloc>(),
              ),
              // Provides market data logic only to this section of the app
              BlocProvider<GameBloc>(
                create: (context) => sl<GameBloc>(),
              ),
            ],
            child: const BaseScreen(),
          ),
        ),
      ),
    ],
    redirect: _authRedirect,
  );

  static String? _authRedirect(BuildContext context, GoRouterState state) {
    final authState = sl<AuthBloc>().state;
    final currentLocation = state.matchedLocation;

    final bool isAuthenticated = authState.isAuthenticated;

    // Define what pages are considered "Auth" pages
    final bool isAuthPage = currentLocation == RouteNames.splash ||
        currentLocation == RouteNames.register ||
        currentLocation == RouteNames.loginScreen ||
        currentLocation == RouteNames.verifyOtp;

    // 1. If the user is authenticated and is currently on an Auth page (like Splash or VerifyOtp)
    // redirect them to the Game Screen (or Home)
    if (isAuthenticated && isAuthPage) {
      return RouteNames.home; // Or RouteNames.home based on your preference
    }

    // 2. If the user is NOT authenticated and tries to access protected pages
    // You can add logic here to force them to Register if they try to access /home directly
    final bool isProtectedRoute = currentLocation == RouteNames.home || currentLocation == RouteNames.gameScreen;
    if (!isAuthenticated && isProtectedRoute) return RouteNames.register;

    return null;
  }}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen(
          (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}