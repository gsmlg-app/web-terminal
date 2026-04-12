import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ThemeModeExtension', () {
    group('fromString', () {
      test('parses "system" string', () {
        expect(ThemeModeExtension.fromString('system'), ThemeMode.system);
      });

      test('parses "light" string', () {
        expect(ThemeModeExtension.fromString('light'), ThemeMode.light);
      });

      test('parses "dark" string', () {
        expect(ThemeModeExtension.fromString('dark'), ThemeMode.dark);
      });

      test('returns system for null', () {
        expect(ThemeModeExtension.fromString(null), ThemeMode.system);
      });

      test('returns system for unknown string', () {
        expect(ThemeModeExtension.fromString('unknown'), ThemeMode.system);
      });
    });

    group('title', () {
      test('system mode has title "System"', () {
        expect(ThemeMode.system.title, 'System');
      });

      test('light mode has title "Light"', () {
        expect(ThemeMode.light.title, 'Light');
      });

      test('dark mode has title "Dark"', () {
        expect(ThemeMode.dark.title, 'Dark');
      });
    });

    group('icon', () {
      testWidgets('system mode has brightness_auto icon', (tester) async {
        await tester.pumpWidget(
          MaterialApp(home: ThemeMode.system.icon),
        );
        expect(find.byIcon(Icons.brightness_auto), findsOneWidget);
      });

      testWidgets('light mode has light_mode icon', (tester) async {
        await tester.pumpWidget(
          MaterialApp(home: ThemeMode.light.icon),
        );
        expect(find.byIcon(Icons.light_mode), findsOneWidget);
      });

      testWidgets('dark mode has dark_mode icon', (tester) async {
        await tester.pumpWidget(
          MaterialApp(home: ThemeMode.dark.icon),
        );
        expect(find.byIcon(Icons.dark_mode), findsOneWidget);
      });
    });

    group('iconOutlined', () {
      testWidgets('system mode has brightness_auto_outlined icon',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(home: ThemeMode.system.iconOutlined),
        );
        expect(find.byIcon(Icons.brightness_auto_outlined), findsOneWidget);
      });

      testWidgets('light mode has light_mode_outlined icon', (tester) async {
        await tester.pumpWidget(
          MaterialApp(home: ThemeMode.light.iconOutlined),
        );
        expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
      });

      testWidgets('dark mode has dark_mode_outlined icon', (tester) async {
        await tester.pumpWidget(
          MaterialApp(home: ThemeMode.dark.iconOutlined),
        );
        expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
      });
    });
  });

  group('DmThemeData.themes', () {
    test('has at least two themes', () {
      expect(DmThemeData.themes.length, greaterThanOrEqualTo(2));
    });

    test('all themes have light and dark variants', () {
      for (final entry in DmThemeData.themes) {
        expect(entry.light, isNotNull);
        expect(entry.dark, isNotNull);
        expect(entry.light.brightness, Brightness.light);
        expect(entry.dark.brightness, Brightness.dark);
      }
    });

    test('all themes have a name', () {
      for (final entry in DmThemeData.themes) {
        expect(entry.name, isNotEmpty);
      }
    });

    test('all themes use Material 3', () {
      for (final entry in DmThemeData.themes) {
        expect(entry.light.useMaterial3, true);
        expect(entry.dark.useMaterial3, true);
      }
    });

    test('each theme has distinct primary colors', () {
      final colorSet = DmThemeData.themes
          .map((e) => e.light.colorScheme.primary.toARGB32())
          .toSet();
      expect(colorSet.length, DmThemeData.themes.length);
    });
  });

  group('DmThemeData factory methods', () {
    test('sunshine returns light theme', () {
      final theme = DmThemeData.sunshine();
      expect(theme.brightness, Brightness.light);
      expect(theme.useMaterial3, true);
    });

    test('moonlight returns dark theme', () {
      final theme = DmThemeData.moonlight();
      expect(theme.brightness, Brightness.dark);
      expect(theme.useMaterial3, true);
    });
  });
}
