import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:web_terminal/destinations.dart';
import 'package:app_locale/app_locale.dart';

void main() {
  group('Destinations static constants', () {
    group('terminalScreenName', () {
      test('is defined', () {
        expect(Destinations.terminalScreenName, isNotNull);
      });

      test('equals "TerminalScreen"', () {
        expect(Destinations.terminalScreenName, 'TerminalScreen');
      });

      test('is a String', () {
        expect(Destinations.terminalScreenName, isA<String>());
      });

      test('is not empty', () {
        expect(Destinations.terminalScreenName, isNotEmpty);
      });
    });

    group('webTerminalScreenName', () {
      test('is defined', () {
        expect(Destinations.webTerminalScreenName, isNotNull);
      });

      test('equals "WebTerminalScreen"', () {
        expect(Destinations.webTerminalScreenName, 'WebTerminalScreen');
      });

      test('is a String', () {
        expect(Destinations.webTerminalScreenName, isA<String>());
      });

      test('is not empty', () {
        expect(Destinations.webTerminalScreenName, isNotEmpty);
      });
    });

    group('settingsScreenName', () {
      test('is defined', () {
        expect(Destinations.settingsScreenName, isNotNull);
      });

      test('equals "Settings"', () {
        expect(Destinations.settingsScreenName, 'Settings');
      });

      test('is a String', () {
        expect(Destinations.settingsScreenName, isA<String>());
      });

      test('is not empty', () {
        expect(Destinations.settingsScreenName, isNotEmpty);
      });
    });

    group('uniqueness', () {
      test('all screen names are unique', () {
        final names = [
          Destinations.terminalScreenName,
          Destinations.webTerminalScreenName,
          Destinations.settingsScreenName,
        ];
        expect(names.toSet().length, names.length,
            reason: 'All screen names should be unique');
      });

      test('terminalScreenName differs from webTerminalScreenName', () {
        expect(
          Destinations.terminalScreenName,
          isNot(equals(Destinations.webTerminalScreenName)),
        );
      });

      test('terminalScreenName differs from settingsScreenName', () {
        expect(
          Destinations.terminalScreenName,
          isNot(equals(Destinations.settingsScreenName)),
        );
      });

      test('webTerminalScreenName differs from settingsScreenName', () {
        expect(
          Destinations.webTerminalScreenName,
          isNot(equals(Destinations.settingsScreenName)),
        );
      });
    });

    group('naming conventions', () {
      test('all names use PascalCase', () {
        // Check that names start with uppercase
        expect(
          Destinations.terminalScreenName[0],
          equals(Destinations.terminalScreenName[0].toUpperCase()),
        );
        expect(
          Destinations.webTerminalScreenName[0],
          equals(Destinations.webTerminalScreenName[0].toUpperCase()),
        );
        expect(
          Destinations.settingsScreenName[0],
          equals(Destinations.settingsScreenName[0].toUpperCase()),
        );
      });

      test('names do not contain spaces', () {
        expect(Destinations.terminalScreenName, isNot(contains(' ')));
        expect(Destinations.webTerminalScreenName, isNot(contains(' ')));
        expect(Destinations.settingsScreenName, isNot(contains(' ')));
      });
    });
  });

  group('Destinations.navs', () {
    test('returns method reference', () {
      expect(Destinations.navs, isNotNull);
    });

    test('is a Function', () {
      expect(Destinations.navs, isA<Function>());
    });

    testWidgets('returns 3 NavigationDestination widgets', (tester) async {
      late List<NavigationDestination> destinations;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocale.localizationsDelegates,
          supportedLocales: AppLocale.supportedLocales,
          home: Builder(
            builder: (context) {
              destinations = Destinations.navs(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(destinations, hasLength(3));
      expect(destinations[0], isA<NavigationDestination>());
      expect(destinations[1], isA<NavigationDestination>());
      expect(destinations[2], isA<NavigationDestination>());
    });

    testWidgets('first destination has terminal icon', (tester) async {
      late List<NavigationDestination> destinations;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocale.localizationsDelegates,
          supportedLocales: AppLocale.supportedLocales,
          home: Builder(
            builder: (context) {
              destinations = Destinations.navs(context);
              return const SizedBox();
            },
          ),
        ),
      );

      final first = destinations[0];
      expect(first.icon, isA<Icon>());
      expect((first.icon as Icon).icon, equals(Icons.terminal_outlined));
      expect(first.selectedIcon, isA<Icon>());
      expect((first.selectedIcon as Icon).icon, equals(Icons.terminal));
    });

    testWidgets('second destination has language icon', (tester) async {
      late List<NavigationDestination> destinations;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocale.localizationsDelegates,
          supportedLocales: AppLocale.supportedLocales,
          home: Builder(
            builder: (context) {
              destinations = Destinations.navs(context);
              return const SizedBox();
            },
          ),
        ),
      );

      final second = destinations[1];
      expect(second.icon, isA<Icon>());
      expect((second.icon as Icon).icon, equals(Icons.language_outlined));
      expect(second.selectedIcon, isA<Icon>());
      expect((second.selectedIcon as Icon).icon, equals(Icons.language));
    });

    testWidgets('third destination has settings icon', (tester) async {
      late List<NavigationDestination> destinations;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocale.localizationsDelegates,
          supportedLocales: AppLocale.supportedLocales,
          home: Builder(
            builder: (context) {
              destinations = Destinations.navs(context);
              return const SizedBox();
            },
          ),
        ),
      );

      final third = destinations[2];
      expect(third.icon, isA<Icon>());
      expect((third.icon as Icon).icon, equals(Icons.settings_outlined));
      expect(third.selectedIcon, isA<Icon>());
      expect((third.selectedIcon as Icon).icon, equals(Icons.settings));
    });

    testWidgets('destinations have correct keys', (tester) async {
      late List<NavigationDestination> destinations;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocale.localizationsDelegates,
          supportedLocales: AppLocale.supportedLocales,
          home: Builder(
            builder: (context) {
              destinations = Destinations.navs(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(destinations[0].key, equals(const Key('TerminalScreen')));
      expect(destinations[1].key, equals(const Key('WebTerminalScreen')));
      expect(destinations[2].key, equals(const Key('Settings')));
    });

    testWidgets('destinations have labels', (tester) async {
      late List<NavigationDestination> destinations;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocale.localizationsDelegates,
          supportedLocales: AppLocale.supportedLocales,
          home: Builder(
            builder: (context) {
              destinations = Destinations.navs(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(destinations[0].label, isNotEmpty);
      expect(destinations[1].label, isNotEmpty);
      expect(destinations[2].label, isNotEmpty);
    });
  });

  group('Destinations.indexOf', () {
    test('returns method reference', () {
      expect(Destinations.indexOf, isNotNull);
    });

    test('is a Function', () {
      expect(Destinations.indexOf, isA<Function>());
    });

    testWidgets('returns 0 for TerminalScreen key', (tester) async {
      late int index;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocale.localizationsDelegates,
          supportedLocales: AppLocale.supportedLocales,
          home: Builder(
            builder: (context) {
              index = Destinations.indexOf(
                const Key('TerminalScreen'),
                context,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(index, equals(0));
    });

    testWidgets('returns 1 for WebTerminalScreen key', (tester) async {
      late int index;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocale.localizationsDelegates,
          supportedLocales: AppLocale.supportedLocales,
          home: Builder(
            builder: (context) {
              index = Destinations.indexOf(
                const Key('WebTerminalScreen'),
                context,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(index, equals(1));
    });

    testWidgets('returns 2 for Settings key', (tester) async {
      late int index;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocale.localizationsDelegates,
          supportedLocales: AppLocale.supportedLocales,
          home: Builder(
            builder: (context) {
              index = Destinations.indexOf(
                const Key('Settings'),
                context,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(index, equals(2));
    });

    testWidgets('returns -1 for unknown key', (tester) async {
      late int index;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocale.localizationsDelegates,
          supportedLocales: AppLocale.supportedLocales,
          home: Builder(
            builder: (context) {
              index = Destinations.indexOf(
                const Key('UnknownScreen'),
                context,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(index, equals(-1));
    });
  });

  group('Destinations.changeHandler', () {
    test('returns method reference', () {
      expect(Destinations.changeHandler, isNotNull);
    });

    test('is a Function', () {
      expect(Destinations.changeHandler, isA<Function>());
    });

    testWidgets('navigates to terminal for index 0', (tester) async {
      String? navigatedTo;

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            name: 'Home',
            builder: (context, state) => Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Destinations.changeHandler(0, context);
                },
                child: const Text('Navigate'),
              ),
            ),
          ),
          GoRoute(
            path: '/terminal',
            name: 'TerminalScreen',
            builder: (context, state) {
              navigatedTo = 'TerminalScreen';
              return const Text('Terminal');
            },
          ),
          GoRoute(
            path: '/web-terminal',
            name: 'WebTerminalScreen',
            builder: (context, state) {
              navigatedTo = 'WebTerminalScreen';
              return const Text('Web Terminal');
            },
          ),
          GoRoute(
            path: '/settings',
            name: 'Settings',
            builder: (context, state) {
              navigatedTo = 'Settings';
              return const Text('Settings');
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocale.localizationsDelegates,
          supportedLocales: AppLocale.supportedLocales,
        ),
      );

      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      expect(navigatedTo, equals('TerminalScreen'));
    });

    testWidgets('navigates to web terminal for index 1', (tester) async {
      String? navigatedTo;

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            name: 'Home',
            builder: (context, state) => Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Destinations.changeHandler(1, context);
                },
                child: const Text('Navigate'),
              ),
            ),
          ),
          GoRoute(
            path: '/terminal',
            name: 'TerminalScreen',
            builder: (context, state) {
              navigatedTo = 'TerminalScreen';
              return const Text('Terminal');
            },
          ),
          GoRoute(
            path: '/web-terminal',
            name: 'WebTerminalScreen',
            builder: (context, state) {
              navigatedTo = 'WebTerminalScreen';
              return const Text('Web Terminal');
            },
          ),
          GoRoute(
            path: '/settings',
            name: 'Settings',
            builder: (context, state) {
              navigatedTo = 'Settings';
              return const Text('Settings');
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocale.localizationsDelegates,
          supportedLocales: AppLocale.supportedLocales,
        ),
      );

      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      expect(navigatedTo, equals('WebTerminalScreen'));
    });

    testWidgets('navigates to settings for index 2', (tester) async {
      String? navigatedTo;

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            name: 'Home',
            builder: (context, state) => Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Destinations.changeHandler(2, context);
                },
                child: const Text('Navigate'),
              ),
            ),
          ),
          GoRoute(
            path: '/terminal',
            name: 'TerminalScreen',
            builder: (context, state) {
              navigatedTo = 'TerminalScreen';
              return const Text('Terminal');
            },
          ),
          GoRoute(
            path: '/web-terminal',
            name: 'WebTerminalScreen',
            builder: (context, state) {
              navigatedTo = 'WebTerminalScreen';
              return const Text('Web Terminal');
            },
          ),
          GoRoute(
            path: '/settings',
            name: 'Settings',
            builder: (context, state) {
              navigatedTo = 'Settings';
              return const Text('Settings');
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocale.localizationsDelegates,
          supportedLocales: AppLocale.supportedLocales,
        ),
      );

      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      expect(navigatedTo, equals('Settings'));
    });

    testWidgets('navigates to first screen for out of bounds index',
        (tester) async {
      String? navigatedTo;

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            name: 'Home',
            builder: (context, state) => Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Destinations.changeHandler(99, context);
                },
                child: const Text('Navigate'),
              ),
            ),
          ),
          GoRoute(
            path: '/terminal',
            name: 'TerminalScreen',
            builder: (context, state) {
              navigatedTo = 'TerminalScreen';
              return const Text('Terminal');
            },
          ),
          GoRoute(
            path: '/web-terminal',
            name: 'WebTerminalScreen',
            builder: (context, state) => const Text('Web Terminal'),
          ),
          GoRoute(
            path: '/settings',
            name: 'Settings',
            builder: (context, state) => const Text('Settings'),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocale.localizationsDelegates,
          supportedLocales: AppLocale.supportedLocales,
        ),
      );

      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      expect(navigatedTo, equals('TerminalScreen'));
    });

    testWidgets('navigates to first screen for negative index', (tester) async {
      String? navigatedTo;

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            name: 'Home',
            builder: (context, state) => Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Destinations.changeHandler(-1, context);
                },
                child: const Text('Navigate'),
              ),
            ),
          ),
          GoRoute(
            path: '/terminal',
            name: 'TerminalScreen',
            builder: (context, state) {
              navigatedTo = 'TerminalScreen';
              return const Text('Terminal');
            },
          ),
          GoRoute(
            path: '/web-terminal',
            name: 'WebTerminalScreen',
            builder: (context, state) => const Text('Web Terminal'),
          ),
          GoRoute(
            path: '/settings',
            name: 'Settings',
            builder: (context, state) => const Text('Settings'),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocale.localizationsDelegates,
          supportedLocales: AppLocale.supportedLocales,
        ),
      );

      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      expect(navigatedTo, equals('TerminalScreen'));
    });

    testWidgets('supports custom screen names', (tester) async {
      String? navigatedTo;

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            name: 'Home',
            builder: (context, state) => Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Destinations.changeHandler(
                    1,
                    context,
                    screenNames: ['Custom1', 'Custom2', 'Custom3'],
                  );
                },
                child: const Text('Navigate'),
              ),
            ),
          ),
          GoRoute(
            path: '/custom1',
            name: 'Custom1',
            builder: (context, state) {
              navigatedTo = 'Custom1';
              return const Text('Custom 1');
            },
          ),
          GoRoute(
            path: '/custom2',
            name: 'Custom2',
            builder: (context, state) {
              navigatedTo = 'Custom2';
              return const Text('Custom 2');
            },
          ),
          GoRoute(
            path: '/custom3',
            name: 'Custom3',
            builder: (context, state) {
              navigatedTo = 'Custom3';
              return const Text('Custom 3');
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocale.localizationsDelegates,
          supportedLocales: AppLocale.supportedLocales,
        ),
      );

      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      expect(navigatedTo, equals('Custom2'));
    });
  });

  group('Destinations class', () {
    test('class exists', () {
      expect(Destinations, isNotNull);
    });

    test('has three screen name constants', () {
      // Verify all three constants are accessible
      expect(Destinations.terminalScreenName, isNotNull);
      expect(Destinations.webTerminalScreenName, isNotNull);
      expect(Destinations.settingsScreenName, isNotNull);
    });

    test('has three method references', () {
      // Verify all three methods are accessible
      expect(Destinations.navs, isNotNull);
      expect(Destinations.indexOf, isNotNull);
      expect(Destinations.changeHandler, isNotNull);
    });
  });
}
