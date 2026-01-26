import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settings_ui/src/tiles/settings_tile.dart';
import 'package:settings_ui/src/utils/platform_utils.dart';
import 'package:settings_ui/src/utils/settings_theme.dart';

void main() {
  group('SettingsTileType', () {
    test('has all expected values', () {
      expect(SettingsTileType.values, hasLength(4));
    });

    test('simpleTile value exists', () {
      expect(SettingsTileType.simpleTile, isNotNull);
    });

    test('switchTile value exists', () {
      expect(SettingsTileType.switchTile, isNotNull);
    });

    test('navigationTile value exists', () {
      expect(SettingsTileType.navigationTile, isNotNull);
    });

    test('checkTile value exists', () {
      expect(SettingsTileType.checkTile, isNotNull);
    });
  });

  group('SettingsTile default constructor', () {
    test('creates simple tile', () {
      final tile = SettingsTile(title: const Text('Title'));
      expect(tile.tileType, equals(SettingsTileType.simpleTile));
    });

    test('stores title widget', () {
      const titleWidget = Text('My Title');
      final tile = SettingsTile(title: titleWidget);
      expect(tile.title, equals(titleWidget));
    });

    test('stores leading widget', () {
      const leadingWidget = Icon(Icons.settings);
      final tile = SettingsTile(
        title: const Text('Title'),
        leading: leadingWidget,
      );
      expect(tile.leading, equals(leadingWidget));
    });

    test('stores trailing widget', () {
      const trailingWidget = Icon(Icons.arrow_forward);
      final tile = SettingsTile(
        title: const Text('Title'),
        trailing: trailingWidget,
      );
      expect(tile.trailing, equals(trailingWidget));
    });

    test('stores value widget', () {
      const valueWidget = Text('Value');
      final tile = SettingsTile(title: const Text('Title'), value: valueWidget);
      expect(tile.value, equals(valueWidget));
    });

    test('stores description widget', () {
      const descWidget = Text('Description');
      final tile = SettingsTile(
        title: const Text('Title'),
        description: descWidget,
      );
      expect(tile.description, equals(descWidget));
    });

    test('defaults enabled to true', () {
      final tile = SettingsTile(title: const Text('Title'));
      expect(tile.enabled, isTrue);
    });

    test('can set enabled to false', () {
      final tile = SettingsTile(title: const Text('Title'), enabled: false);
      expect(tile.enabled, isFalse);
    });

    test('sets onToggle to null', () {
      final tile = SettingsTile(title: const Text('Title'));
      expect(tile.onToggle, isNull);
    });

    test('sets initialValue to null', () {
      final tile = SettingsTile(title: const Text('Title'));
      expect(tile.initialValue, isNull);
    });

    test('sets activeSwitchColor to null', () {
      final tile = SettingsTile(title: const Text('Title'));
      expect(tile.activeSwitchColor, isNull);
    });

    test('sets checked to null', () {
      final tile = SettingsTile(title: const Text('Title'));
      expect(tile.checked, isNull);
    });
  });

  group('SettingsTile.navigation', () {
    test('creates navigation tile', () {
      final tile = SettingsTile.navigation(title: const Text('Title'));
      expect(tile.tileType, equals(SettingsTileType.navigationTile));
    });

    test('stores all properties', () {
      const titleWidget = Text('Nav Title');
      const leadingWidget = Icon(Icons.person);
      const valueWidget = Text('Value');
      callback(BuildContext ctx) {}

      final tile = SettingsTile.navigation(
        title: titleWidget,
        leading: leadingWidget,
        value: valueWidget,
        onPressed: callback,
      );

      expect(tile.title, equals(titleWidget));
      expect(tile.leading, equals(leadingWidget));
      expect(tile.value, equals(valueWidget));
      expect(tile.onPressed, equals(callback));
    });
  });

  group('SettingsTile.switchTile', () {
    test('creates switch tile', () {
      final tile = SettingsTile.switchTile(
        title: const Text('Title'),
        initialValue: false,
        onToggle: (value) {},
      );
      expect(tile.tileType, equals(SettingsTileType.switchTile));
    });

    test('stores initialValue', () {
      final tile = SettingsTile.switchTile(
        title: const Text('Title'),
        initialValue: true,
        onToggle: (value) {},
      );
      expect(tile.initialValue, isTrue);
    });

    test('stores onToggle callback', () {
      callback(bool value) {}
      final tile = SettingsTile.switchTile(
        title: const Text('Title'),
        initialValue: false,
        onToggle: callback,
      );
      expect(tile.onToggle, equals(callback));
    });

    test('stores activeSwitchColor', () {
      final tile = SettingsTile.switchTile(
        title: const Text('Title'),
        initialValue: false,
        onToggle: (value) {},
        activeSwitchColor: Colors.green,
      );
      expect(tile.activeSwitchColor, equals(Colors.green));
    });

    test('sets value to null', () {
      final tile = SettingsTile.switchTile(
        title: const Text('Title'),
        initialValue: false,
        onToggle: (value) {},
      );
      expect(tile.value, isNull);
    });

    test('sets checked to null', () {
      final tile = SettingsTile.switchTile(
        title: const Text('Title'),
        initialValue: false,
        onToggle: (value) {},
      );
      expect(tile.checked, isNull);
    });
  });

  group('SettingsTile.checkTile', () {
    test('creates check tile', () {
      final tile = SettingsTile.checkTile(
        title: const Text('Title'),
        checked: true,
      );
      expect(tile.tileType, equals(SettingsTileType.checkTile));
    });

    test('stores checked value', () {
      final tile = SettingsTile.checkTile(
        title: const Text('Title'),
        checked: true,
      );
      expect(tile.checked, isTrue);
    });

    test('stores checked false', () {
      final tile = SettingsTile.checkTile(
        title: const Text('Title'),
        checked: false,
      );
      expect(tile.checked, isFalse);
    });

    test('sets onToggle to null', () {
      final tile = SettingsTile.checkTile(
        title: const Text('Title'),
        checked: true,
      );
      expect(tile.onToggle, isNull);
    });

    test('sets initialValue to null', () {
      final tile = SettingsTile.checkTile(
        title: const Text('Title'),
        checked: true,
      );
      expect(tile.initialValue, isNull);
    });

    test('sets activeSwitchColor to null', () {
      final tile = SettingsTile.checkTile(
        title: const Text('Title'),
        checked: true,
      );
      expect(tile.activeSwitchColor, isNull);
    });
  });

  group('addCheckedTrailing', () {
    testWidgets('returns check icon when checked is true', (tester) async {
      final tile = SettingsTile.checkTile(
        title: const Text('Title'),
        checked: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTheme(
              themeData: const SettingsThemeData(),
              platform: DevicePlatform.android,
              child: Builder(
                builder: (context) {
                  final trailing = tile.addCheckedTrailing(context);
                  expect(trailing, isA<Icon>());
                  final icon = trailing as Icon;
                  expect(icon.icon, equals(Icons.check));
                  expect(icon.color, equals(Colors.lightGreen));
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );
    });

    testWidgets('returns transparent check when checked is false', (
      tester,
    ) async {
      final tile = SettingsTile.checkTile(
        title: const Text('Title'),
        checked: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTheme(
              themeData: const SettingsThemeData(),
              platform: DevicePlatform.android,
              child: Builder(
                builder: (context) {
                  final trailing = tile.addCheckedTrailing(context);
                  expect(trailing, isA<Icon>());
                  final icon = trailing as Icon;
                  expect(icon.icon, equals(Icons.check));
                  expect(icon.color, equals(Colors.transparent));
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );
    });

    testWidgets('returns trailing when checked is null', (tester) async {
      const trailingWidget = Icon(Icons.arrow_forward);
      final tile = SettingsTile(
        title: const Text('Title'),
        trailing: trailingWidget,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTheme(
              themeData: const SettingsThemeData(),
              platform: DevicePlatform.android,
              child: Builder(
                builder: (context) {
                  final trailing = tile.addCheckedTrailing(context);
                  expect(trailing, equals(trailingWidget));
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );
    });
  });

  group('SettingsTile build', () {
    testWidgets('builds for android platform', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTheme(
              themeData: const SettingsThemeData(),
              platform: DevicePlatform.android,
              child: SettingsTile(title: const Text('Test Tile')),
            ),
          ),
        ),
      );

      expect(find.text('Test Tile'), findsOneWidget);
    });

    testWidgets('builds for iOS platform', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTheme(
              themeData: const SettingsThemeData(),
              platform: DevicePlatform.iOS,
              child: SettingsTile(title: const Text('Test Tile')),
            ),
          ),
        ),
      );

      expect(find.text('Test Tile'), findsOneWidget);
    });

    testWidgets('builds for web platform', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTheme(
              themeData: const SettingsThemeData(),
              platform: DevicePlatform.web,
              child: SettingsTile(title: const Text('Test Tile')),
            ),
          ),
        ),
      );

      expect(find.text('Test Tile'), findsOneWidget);
    });

    testWidgets('builds for linux platform', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTheme(
              themeData: const SettingsThemeData(),
              platform: DevicePlatform.linux,
              child: SettingsTile(title: const Text('Test Tile')),
            ),
          ),
        ),
      );

      expect(find.text('Test Tile'), findsOneWidget);
    });

    testWidgets('builds for macOS platform', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTheme(
              themeData: const SettingsThemeData(),
              platform: DevicePlatform.macOS,
              child: SettingsTile(title: const Text('Test Tile')),
            ),
          ),
        ),
      );

      expect(find.text('Test Tile'), findsOneWidget);
    });

    testWidgets('builds for windows platform', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTheme(
              themeData: const SettingsThemeData(),
              platform: DevicePlatform.windows,
              child: SettingsTile(title: const Text('Test Tile')),
            ),
          ),
        ),
      );

      expect(find.text('Test Tile'), findsOneWidget);
    });
  });

  group('key parameter', () {
    test('stores key in default constructor', () {
      final key = UniqueKey();
      final tile = SettingsTile(title: const Text('Title'), key: key);
      expect(tile.key, equals(key));
    });

    test('stores key in navigation constructor', () {
      final key = UniqueKey();
      final tile = SettingsTile.navigation(
        title: const Text('Title'),
        key: key,
      );
      expect(tile.key, equals(key));
    });

    test('stores key in switchTile constructor', () {
      final key = UniqueKey();
      final tile = SettingsTile.switchTile(
        title: const Text('Title'),
        initialValue: false,
        onToggle: (v) {},
        key: key,
      );
      expect(tile.key, equals(key));
    });

    test('stores key in checkTile constructor', () {
      final key = UniqueKey();
      final tile = SettingsTile.checkTile(
        title: const Text('Title'),
        checked: true,
        key: key,
      );
      expect(tile.key, equals(key));
    });
  });
}
