import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settings_ui/src/sections/settings_section.dart';
import 'package:settings_ui/src/tiles/settings_tile.dart';
import 'package:settings_ui/src/utils/platform_utils.dart';
import 'package:settings_ui/src/utils/settings_theme.dart';

void main() {
  group('SettingsSection', () {
    test('can be const constructed with required tiles', () {
      const section = SettingsSection(tiles: []);
      expect(section, isA<SettingsSection>());
    });

    test('stores tiles list', () {
      final tiles = [
        SettingsTile(title: const Text('Tile 1')),
        SettingsTile(title: const Text('Tile 2')),
      ];
      final section = SettingsSection(tiles: tiles);
      expect(section.tiles, equals(tiles));
    });

    test('stores title widget', () {
      const titleWidget = Text('Section Title');
      const section = SettingsSection(
        tiles: [],
        title: titleWidget,
      );
      expect(section.title, equals(titleWidget));
    });

    test('title defaults to null', () {
      const section = SettingsSection(tiles: []);
      expect(section.title, isNull);
    });

    test('stores margin', () {
      const margin = EdgeInsetsDirectional.all(16);
      const section = SettingsSection(
        tiles: [],
        margin: margin,
      );
      expect(section.margin, equals(margin));
    });

    test('margin defaults to null', () {
      const section = SettingsSection(tiles: []);
      expect(section.margin, isNull);
    });

    test('stores key', () {
      final key = UniqueKey();
      final section = SettingsSection(tiles: const [], key: key);
      expect(section.key, equals(key));
    });

    testWidgets('builds for android platform', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTheme(
              themeData: const SettingsThemeData(),
              platform: DevicePlatform.android,
              child: SettingsSection(
                title: const Text('Test Section'),
                tiles: [
                  SettingsTile(title: const Text('Tile')),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Section'), findsOneWidget);
      expect(find.text('Tile'), findsOneWidget);
    });

    testWidgets('builds for iOS platform', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTheme(
              themeData: const SettingsThemeData(),
              platform: DevicePlatform.iOS,
              child: SettingsSection(
                title: const Text('Test Section'),
                tiles: [
                  SettingsTile(title: const Text('Tile')),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Section'), findsOneWidget);
      expect(find.text('Tile'), findsOneWidget);
    });

    testWidgets('builds for web platform', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTheme(
              themeData: const SettingsThemeData(),
              platform: DevicePlatform.web,
              child: SettingsSection(
                title: const Text('Test Section'),
                tiles: [
                  SettingsTile(title: const Text('Tile')),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Section'), findsOneWidget);
      expect(find.text('Tile'), findsOneWidget);
    });

    testWidgets('builds for linux platform', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTheme(
              themeData: const SettingsThemeData(),
              platform: DevicePlatform.linux,
              child: SettingsSection(
                title: const Text('Test Section'),
                tiles: [
                  SettingsTile(title: const Text('Tile')),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Section'), findsOneWidget);
      expect(find.text('Tile'), findsOneWidget);
    });

    testWidgets('builds for macOS platform', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTheme(
              themeData: const SettingsThemeData(),
              platform: DevicePlatform.macOS,
              child: SettingsSection(
                title: const Text('Test Section'),
                tiles: [
                  SettingsTile(title: const Text('Tile')),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Section'), findsOneWidget);
      expect(find.text('Tile'), findsOneWidget);
    });

    testWidgets('builds for windows platform', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTheme(
              themeData: const SettingsThemeData(),
              platform: DevicePlatform.windows,
              child: SettingsSection(
                title: const Text('Test Section'),
                tiles: [
                  SettingsTile(title: const Text('Tile')),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Section'), findsOneWidget);
      expect(find.text('Tile'), findsOneWidget);
    });

    testWidgets('builds with multiple tiles', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTheme(
              themeData: const SettingsThemeData(),
              platform: DevicePlatform.android,
              child: SettingsSection(
                tiles: [
                  SettingsTile(title: const Text('Tile 1')),
                  SettingsTile(title: const Text('Tile 2')),
                  SettingsTile(title: const Text('Tile 3')),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Tile 1'), findsOneWidget);
      expect(find.text('Tile 2'), findsOneWidget);
      expect(find.text('Tile 3'), findsOneWidget);
    });

    testWidgets('builds with no title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTheme(
              themeData: const SettingsThemeData(),
              platform: DevicePlatform.android,
              child: SettingsSection(
                tiles: [
                  SettingsTile(title: const Text('Tile')),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Tile'), findsOneWidget);
    });

    testWidgets('builds with empty tiles list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTheme(
              themeData: const SettingsThemeData(),
              platform: DevicePlatform.android,
              child: const SettingsSection(
                title: Text('Empty Section'),
                tiles: [],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Empty Section'), findsOneWidget);
    });
  });
}
