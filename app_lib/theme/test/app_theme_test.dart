import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ThemeModeExtension', () {
    group('fromString', () {
      test('parses "system" string', () {
        expect(ThemeModeExtension.fromString('system'), ThemeMode.system);
      });

      test('parses "ThemeMode.system" string', () {
        expect(ThemeModeExtension.fromString('ThemeMode.system'),
            ThemeMode.system);
      });

      test('parses "light" string', () {
        expect(ThemeModeExtension.fromString('light'), ThemeMode.light);
      });

      test('parses "ThemeMode.light" string', () {
        expect(
            ThemeModeExtension.fromString('ThemeMode.light'), ThemeMode.light);
      });

      test('parses "dark" string', () {
        expect(ThemeModeExtension.fromString('dark'), ThemeMode.dark);
      });

      test('parses "ThemeMode.dark" string', () {
        expect(ThemeModeExtension.fromString('ThemeMode.dark'), ThemeMode.dark);
      });

      test('returns system for null', () {
        expect(ThemeModeExtension.fromString(null), ThemeMode.system);
      });

      test('returns system for unknown string', () {
        expect(ThemeModeExtension.fromString('unknown'), ThemeMode.system);
      });

      test('returns system for empty string', () {
        expect(ThemeModeExtension.fromString(''), ThemeMode.system);
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

  group('themeList', () {
    test('has all four themes', () {
      expect(themeList.length, 4);
    });

    test('contains VioletTheme', () {
      expect(themeList.any((t) => t is VioletTheme), true);
    });

    test('contains GreenTheme', () {
      expect(themeList.any((t) => t is GreenTheme), true);
    });

    test('contains FireTheme', () {
      expect(themeList.any((t) => t is FireTheme), true);
    });

    test('contains WheatTheme', () {
      expect(themeList.any((t) => t is WheatTheme), true);
    });
  });

  group('AppTheme', () {
    test('toString returns theme name', () {
      final theme = VioletTheme();
      expect(theme.toString(), 'Violet');
    });
  });

  group('VioletTheme', () {
    late VioletTheme theme;

    setUp(() {
      theme = VioletTheme();
    });

    test('has correct name', () {
      expect(theme.name, 'Violet');
    });

    test('has light theme', () {
      expect(theme.lightTheme, isNotNull);
      expect(theme.lightTheme.brightness, Brightness.light);
    });

    test('has dark theme', () {
      expect(theme.darkTheme, isNotNull);
      expect(theme.darkTheme.brightness, Brightness.dark);
    });

    test('uses Material 3', () {
      expect(theme.lightTheme.useMaterial3, true);
      expect(theme.darkTheme.useMaterial3, true);
    });

    test('factory returns same-type instance', () {
      final theme1 = VioletTheme();
      final theme2 = VioletTheme();
      expect(theme1.name, theme2.name);
    });
  });

  group('GreenTheme', () {
    late GreenTheme theme;

    setUp(() {
      theme = GreenTheme();
    });

    test('has correct name', () {
      expect(theme.name, 'Green');
    });

    test('has light theme', () {
      expect(theme.lightTheme, isNotNull);
      expect(theme.lightTheme.brightness, Brightness.light);
    });

    test('has dark theme', () {
      expect(theme.darkTheme, isNotNull);
      expect(theme.darkTheme.brightness, Brightness.dark);
    });

    test('uses Material 3', () {
      expect(theme.lightTheme.useMaterial3, true);
      expect(theme.darkTheme.useMaterial3, true);
    });
  });

  group('FireTheme', () {
    late FireTheme theme;

    setUp(() {
      theme = FireTheme();
    });

    test('has correct name', () {
      expect(theme.name, 'Fire');
    });

    test('has light theme', () {
      expect(theme.lightTheme, isNotNull);
      expect(theme.lightTheme.brightness, Brightness.light);
    });

    test('has dark theme', () {
      expect(theme.darkTheme, isNotNull);
      expect(theme.darkTheme.brightness, Brightness.dark);
    });

    test('uses Material 3', () {
      expect(theme.lightTheme.useMaterial3, true);
      expect(theme.darkTheme.useMaterial3, true);
    });
  });

  group('WheatTheme', () {
    late WheatTheme theme;

    setUp(() {
      theme = WheatTheme();
    });

    test('has correct name', () {
      expect(theme.name, 'Wheat');
    });

    test('has light theme', () {
      expect(theme.lightTheme, isNotNull);
      expect(theme.lightTheme.brightness, Brightness.light);
    });

    test('has dark theme', () {
      expect(theme.darkTheme, isNotNull);
      expect(theme.darkTheme.brightness, Brightness.dark);
    });

    test('uses Material 3', () {
      expect(theme.lightTheme.useMaterial3, true);
      expect(theme.darkTheme.useMaterial3, true);
    });
  });

  group('DynamicTheme', () {
    test('creates theme from seed color', () {
      final theme = DynamicTheme.fromSeed(Colors.blue);
      expect(theme.name, 'Dynamic');
    });

    test('has light theme with correct brightness', () {
      final theme = DynamicTheme.fromSeed(Colors.purple);
      expect(theme.lightTheme, isNotNull);
      expect(theme.lightTheme.brightness, Brightness.light);
    });

    test('has dark theme with correct brightness', () {
      final theme = DynamicTheme.fromSeed(Colors.purple);
      expect(theme.darkTheme, isNotNull);
      expect(theme.darkTheme.brightness, Brightness.dark);
    });

    test('uses Material 3', () {
      final theme = DynamicTheme.fromSeed(Colors.teal);
      expect(theme.lightTheme.useMaterial3, true);
      expect(theme.darkTheme.useMaterial3, true);
    });

    test('different seed colors produce different color schemes', () {
      final blueTheme = DynamicTheme.fromSeed(Colors.blue);
      final redTheme = DynamicTheme.fromSeed(Colors.red);
      expect(blueTheme.lightTheme.colorScheme.primary,
          isNot(redTheme.lightTheme.colorScheme.primary));
    });
  });

  group('Theme color schemes', () {
    test('each theme has distinct color schemes', () {
      final colorSchemes = themeList
          .map((t) => t.lightTheme.colorScheme.primary.toARGB32())
          .toSet();
      // All themes should have different primary colors
      expect(colorSchemes.length, themeList.length);
    });

    test('light and dark variants have similar primary color hue', () {
      for (final theme in themeList) {
        // Light and dark should have similar primary color base (within 15 degrees)
        // Material Design 3 may adjust hue slightly for accessibility
        expect(
          HSLColor.fromColor(theme.lightTheme.colorScheme.primary).hue,
          closeTo(
            HSLColor.fromColor(theme.darkTheme.colorScheme.primary).hue,
            15.0,
          ),
        );
      }
    });
  });
}
