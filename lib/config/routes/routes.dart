import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/base/presentation/pages/splash_screen.dart';
import '../../utils/di/service_locator.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: kDebugMode,
    refreshListenable: GoRouterRefreshStream(sl<AuthBloc>().stream),
    routes: [
      GoRoute(
          path: '/login',
        name: 'login',
        builder: (context, state) => const RegisterPage(),
      ),

      GoRoute(
        path: '/',
        redirect: (_, __) => '/splash',
      ),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      // ...UserRouter.routes,
      // ...AdminRouter.routes,
    ],
    redirect: _authRedirect,
  );


  static String? _authRedirect(BuildContext context, GoRouterState state) {
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;

    final currentLocation = state.matchedLocation;
    final isGoingToAdminLogin = currentLocation == '/admin-login';
    final isGoingToSplash = currentLocation == '/splash';
    final isGoingToAdmin = currentLocation.startsWith('/admin');

    final user = authState.userEntity?.whenOrNull(success: (data) => data);
    final isAuthenticated = authState.isAuthenticated;
    final isAdminOrSuperAdmin = user?.role?.toLowerCase() == 'admin' || user?.role?.toLowerCase() == 'superadmin';

    // Allow splash screen always
    if (isGoingToSplash) return null;


    // ==================== A. ALREADY AUTHENTICATED REDIRECT ====================
    // If user is already authenticated and is trying to visit /admin-login, redirect them.
    if (isGoingToAdminLogin && isAuthenticated) {
      if (isAdminOrSuperAdmin) {
        return '/admin/dashboard';
      } else {
        return '/home';
      }
    }


    // ==================== B. ADMIN ROUTE PROTECTION ====================
    // if (isGoingToAdmin && !isGoingToAdminLogin) {
    //   if (!isAuthenticated || !isAdminOrSuperAdmin) {
    //     // Not logged in OR not an Admin, redirect to admin login
    //     return '/admin-login';
    //   }
    //   // Logged in as Admin, allow access
    //   return null;
    // }

    // Allow all other routes (like /home for users)
    return null;
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
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