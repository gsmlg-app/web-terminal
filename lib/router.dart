import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:app_feedback/app_feedback.dart';
import 'package:web_terminal/screens/error/error_screen.dart';
import 'package:web_terminal/screens/settings/_setting_route.dart';
import 'package:web_terminal/screens/splash/splash_screen.dart';
import 'package:web_terminal/screens/terminal/terminal_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>(debugLabel: 'routerKey');

final router = GoRouter(
  navigatorKey: navigatorKey,
  debugLogDiagnostics: true,
  initialLocation: SplashScreen.path,
  routes: routes,
  redirect: (BuildContext context, GoRouterState state) {
    return null;
  },
  errorBuilder: (context, state) {
    return ErrorScreen(routerState: state);
  },
);

List<GoRoute> routes = [
  GoRoute(
    name: SplashScreen.name,
    path: SplashScreen.path,
    pageBuilder: (context, state) {
      return NoTransitionPage<void>(
        key: state.pageKey,
        child: const SplashScreen(),
      );
    },
  ),
  GoRoute(
    name: ErrorScreen.name,
    path: ErrorScreen.path,
    pageBuilder: (context, state) {
      return NoTransitionPage<void>(
        key: state.pageKey,
        child: ErrorScreen(routerState: state),
      );
    },
  ),
  settingRoute,
  GoRoute(
    name: TerminalScreen.name,
    path: TerminalScreen.path,
    pageBuilder: (context, state) {
      return NoTransitionPage<void>(
        key: state.pageKey,
        child: const TerminalScreen(),
      );
    },
  ),
];
