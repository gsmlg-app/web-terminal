import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settings_ui/src/utils/platform_utils.dart';
import 'package:settings_ui/src/utils/settings_theme.dart';

void main() {
  group('SettingsThemeData', () {
    test('can be constructed with no parameters', () {
      const themeData = SettingsThemeData();
      expect(themeData, isA<SettingsThemeData>());
    });

    test('stores all color properties', () {
      const themeData = SettingsThemeData(
        settingsListBackground: Colors.red,
        trailingTextColor: Colors.blue,
        leadingIconsColor: Colors.green,
        settingsSectionBackground: Colors.yellow,
        dividerColor: Colors.orange,
        tileDescriptionTextColor: Colors.purple,
        tileHighlightColor: Colors.cyan,
        titleTextColor: Colors.pink,
        settingsTileTextColor: Colors.teal,
        inactiveTitleColor: Colors.grey,
        inactiveSubtitleColor: Colors.brown,
      );

      expect(themeData.settingsListBackground, equals(Colors.red));
      expect(themeData.trailingTextColor, equals(Colors.blue));
      expect(themeData.leadingIconsColor, equals(Colors.green));
      expect(themeData.settingsSectionBackground, equals(Colors.yellow));
      expect(themeData.dividerColor, equals(Colors.orange));
      expect(themeData.tileDescriptionTextColor, equals(Colors.purple));
      expect(themeData.tileHighlightColor, equals(Colors.cyan));
      expect(themeData.titleTextColor, equals(Colors.pink));
      expect(themeData.settingsTileTextColor, equals(Colors.teal));
      expect(themeData.inactiveTitleColor, equals(Colors.grey));
      expect(themeData.inactiveSubtitleColor, equals(Colors.brown));
    });

    test('defaults all properties to null', () {
      const themeData = SettingsThemeData();

      expect(themeData.settingsListBackground, isNull);
      expect(themeData.trailingTextColor, isNull);
      expect(themeData.leadingIconsColor, isNull);
      expect(themeData.settingsSectionBackground, isNull);
      expect(themeData.dividerColor, isNull);
      expect(themeData.tileDescriptionTextColor, isNull);
      expect(themeData.tileHighlightColor, isNull);
      expect(themeData.titleTextColor, isNull);
      expect(themeData.settingsTileTextColor, isNull);
      expect(themeData.inactiveTitleColor, isNull);
      expect(themeData.inactiveSubtitleColor, isNull);
    });

    group('copyWith', () {
      test('returns new instance with no changes when called with no args', () {
        const original = SettingsThemeData(
          settingsListBackground: Colors.red,
          titleTextColor: Colors.blue,
        );
        final copied = original.copyWith();

        expect(copied.settingsListBackground, equals(Colors.red));
        expect(copied.titleTextColor, equals(Colors.blue));
      });

      test('updates specified fields', () {
        const original = SettingsThemeData(
          settingsListBackground: Colors.red,
          titleTextColor: Colors.blue,
        );
        final copied = original.copyWith(
          settingsListBackground: Colors.green,
        );

        expect(copied.settingsListBackground, equals(Colors.green));
        expect(copied.titleTextColor, equals(Colors.blue));
      });

      test('can update all fields', () {
        const original = SettingsThemeData();
        final copied = original.copyWith(
          settingsListBackground: Colors.red,
          trailingTextColor: Colors.blue,
          leadingIconsColor: Colors.green,
          settingsSectionBackground: Colors.yellow,
          dividerColor: Colors.orange,
          tileDescriptionTextColor: Colors.purple,
          tileHighlightColor: Colors.cyan,
          titleTextColor: Colors.pink,
          settingsTileTextColor: Colors.teal,
          inactiveTitleColor: Colors.grey,
          inactiveSubtitleColor: Colors.brown,
        );

        expect(copied.settingsListBackground, equals(Colors.red));
        expect(copied.trailingTextColor, equals(Colors.blue));
        expect(copied.leadingIconsColor, equals(Colors.green));
        expect(copied.settingsSectionBackground, equals(Colors.yellow));
        expect(copied.dividerColor, equals(Colors.orange));
        expect(copied.tileDescriptionTextColor, equals(Colors.purple));
        expect(copied.tileHighlightColor, equals(Colors.cyan));
        expect(copied.titleTextColor, equals(Colors.pink));
        expect(copied.settingsTileTextColor, equals(Colors.teal));
        expect(copied.inactiveTitleColor, equals(Colors.grey));
        expect(copied.inactiveSubtitleColor, equals(Colors.brown));
      });
    });

    group('merge', () {
      test('returns self when theme is null', () {
        const original = SettingsThemeData(
          settingsListBackground: Colors.red,
        );
        final merged = original.merge(theme: null);

        expect(merged.settingsListBackground, equals(Colors.red));
      });

      test('overrides with values from provided theme', () {
        const original = SettingsThemeData(
          settingsListBackground: Colors.red,
          titleTextColor: Colors.blue,
        );
        const other = SettingsThemeData(
          settingsListBackground: Colors.green,
        );
        final merged = original.merge(theme: other);

        expect(merged.settingsListBackground, equals(Colors.green));
        // titleTextColor should remain from original (not null override)
      });
    });

    group('withColorScheme', () {
      test('creates android theme for android platform', () {
        final colorScheme = ColorScheme.fromSeed(seedColor: Colors.blue);
        final themeData = SettingsThemeData.withColorScheme(
          colorScheme,
          DevicePlatform.android,
        );

        expect(themeData, isA<SettingsThemeData>());
        expect(themeData.settingsListBackground, isNotNull);
      });

      test('creates ios theme for iOS platform', () {
        final colorScheme = ColorScheme.fromSeed(seedColor: Colors.blue);
        final themeData = SettingsThemeData.withColorScheme(
          colorScheme,
          DevicePlatform.iOS,
        );

        expect(themeData, isA<SettingsThemeData>());
        expect(themeData.settingsSectionBackground, isNotNull);
      });

      test('creates web theme for web platform', () {
        final colorScheme = ColorScheme.fromSeed(seedColor: Colors.blue);
        final themeData = SettingsThemeData.withColorScheme(
          colorScheme,
          DevicePlatform.web,
        );

        expect(themeData, isA<SettingsThemeData>());
        expect(themeData.settingsSectionBackground, isNotNull);
      });

      test('creates linux theme using android style', () {
        final colorScheme = ColorScheme.fromSeed(seedColor: Colors.blue);
        final themeData = SettingsThemeData.withColorScheme(
          colorScheme,
          DevicePlatform.linux,
        );

        expect(themeData, isA<SettingsThemeData>());
      });

      test('creates macOS theme using ios style', () {
        final colorScheme = ColorScheme.fromSeed(seedColor: Colors.blue);
        final themeData = SettingsThemeData.withColorScheme(
          colorScheme,
          DevicePlatform.macOS,
        );

        expect(themeData, isA<SettingsThemeData>());
        expect(themeData.settingsSectionBackground, isNotNull);
      });

      test('creates windows theme using ios style', () {
        final colorScheme = ColorScheme.fromSeed(seedColor: Colors.blue);
        final themeData = SettingsThemeData.withColorScheme(
          colorScheme,
          DevicePlatform.windows,
        );

        expect(themeData, isA<SettingsThemeData>());
      });

      test('auto-detects platform when null', () {
        final colorScheme = ColorScheme.fromSeed(seedColor: Colors.blue);
        final themeData = SettingsThemeData.withColorScheme(
          colorScheme,
          null,
        );

        expect(themeData, isA<SettingsThemeData>());
      });
    });
  });

  group('SettingsTheme', () {
    testWidgets('provides theme data to descendants', (tester) async {
      const themeData = SettingsThemeData(
        settingsListBackground: Colors.red,
      );

      late SettingsTheme? foundTheme;

      await tester.pumpWidget(
        MaterialApp(
          home: SettingsTheme(
            themeData: themeData,
            platform: DevicePlatform.android,
            child: Builder(
              builder: (context) {
                foundTheme = SettingsTheme.maybeOf(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(foundTheme, isNotNull);
      expect(
        foundTheme!.themeData.settingsListBackground,
        equals(Colors.red),
      );
    });

    testWidgets('of throws assertion when no theme found', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              // This should throw an assertion
              expect(
                () => SettingsTheme.of(context),
                throwsA(isA<AssertionError>()),
              );
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('maybeOf returns null when no theme found', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(SettingsTheme.maybeOf(context), isNull);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('stores platform value', (tester) async {
      late SettingsTheme? foundTheme;

      await tester.pumpWidget(
        MaterialApp(
          home: SettingsTheme(
            themeData: const SettingsThemeData(),
            platform: DevicePlatform.iOS,
            child: Builder(
              builder: (context) {
                foundTheme = SettingsTheme.maybeOf(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(foundTheme!.platform, equals(DevicePlatform.iOS));
    });

    testWidgets('updateShouldNotify returns true', (tester) async {
      // Create theme with test to verify updateShouldNotify behavior
      final theme1 = SettingsTheme(
        themeData: const SettingsThemeData(),
        platform: DevicePlatform.android,
        child: const SizedBox(),
      );
      final theme2 = SettingsTheme(
        themeData: const SettingsThemeData(),
        platform: DevicePlatform.iOS,
        child: const SizedBox(),
      );

      expect(theme1.updateShouldNotify(theme2), isTrue);
    });
  });
}
