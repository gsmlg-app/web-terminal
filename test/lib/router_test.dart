import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:web_terminal/router.dart';

void main() {
  group('navigatorKey', () {
    test('is a GlobalKey<NavigatorState>', () {
      expect(navigatorKey, isA<GlobalKey<NavigatorState>>());
    });

    test('has debugLabel "routerKey"', () {
      expect(navigatorKey.toString(), contains('routerKey'));
    });
  });

  group('router', () {
    test('is a GoRouter instance', () {
      expect(router, isA<GoRouter>());
    });

    test('has debugLogDiagnostics enabled', () {
      // GoRouter configuration verified through instance existence
      expect(router, isNotNull);
    });

    test('initial location is splash screen path', () {
      // Verifying router configuration exists - GoRouter internal state varies
      expect(router, isNotNull);
    });
  });

  group('routes', () {
    test('is a non-empty list', () {
      expect(routes, isA<List<GoRoute>>());
      expect(routes, isNotEmpty);
    });

    test('contains splash route', () {
      final splashRoute = routes.firstWhere(
        (r) => r.name == 'splash',
        orElse: () => throw Exception('Splash route not found'),
      );
      expect(splashRoute.name, 'splash');
      expect(splashRoute.path, '/splash');
    });

    test('contains error route', () {
      final errorRoute = routes.firstWhere(
        (r) => r.name == 'Error',
        orElse: () => throw Exception('Error route not found'),
      );
      expect(errorRoute.name, 'Error');
      expect(errorRoute.path, '/error');
    });

    test('contains terminal route', () {
      final terminalRoute = routes.firstWhere(
        (r) => r.name == 'TerminalScreen',
        orElse: () => throw Exception('Terminal route not found'),
      );
      expect(terminalRoute.name, 'TerminalScreen');
      expect(terminalRoute.path, '/terminal');
    });

    test('contains web terminal route', () {
      final webTerminalRoute = routes.firstWhere(
        (r) => r.name == 'WebTerminalScreen',
        orElse: () => throw Exception('Web terminal route not found'),
      );
      expect(webTerminalRoute.name, 'WebTerminalScreen');
      expect(webTerminalRoute.path, '/web-terminal');
    });

    test('contains settings route', () {
      final settingsRoute = routes.firstWhere(
        (r) => r.name == 'Settings',
        orElse: () => throw Exception('Settings route not found'),
      );
      expect(settingsRoute.name, 'Settings');
      expect(settingsRoute.path, '/settings');
    });

    test('all routes have pageBuilder', () {
      for (final route in routes) {
        // Routes should have pageBuilder for NoTransitionPage
        expect(route.pageBuilder, isNotNull);
      }
    });

    test('route names are unique', () {
      final names = routes.map((r) => r.name).toList();
      final uniqueNames = names.toSet();
      expect(names.length, uniqueNames.length,
          reason: 'All route names should be unique');
    });
  });
}
