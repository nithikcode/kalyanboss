import 'package:flutter/material.dart';

/// A global route observer that tracks the currently visible route name.
class AppRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  static String? currentRouteName;

  static String? get currentRoute => currentRouteName;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _updateCurrentRoute(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) _updateCurrentRoute(newRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _updateCurrentRoute(previousRoute);
    } else {
      currentRouteName = null; // No routes left
    }
  }

  void _updateCurrentRoute(Route route) {
    if (route is PageRoute) {
      currentRouteName = route.settings.name;
      debugPrint("AppRouteObserver: current route = $currentRouteName");
    }
  }
}

/// Create a single global instance
final appRouteObserver = AppRouteObserver();
