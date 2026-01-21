import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settings_ui/src/list/settings_list.dart';
import 'package:settings_ui/src/sections/settings_section.dart';
import 'package:settings_ui/src/tiles/settings_tile.dart';
import 'package:settings_ui/src/utils/platform_utils.dart';

void main() {
  group('SettingsList', () {
    test('can be const constructed with required sections', () {
      const list = SettingsList(sections: []);
      expect(list, isA<SettingsList>());
    });

    test('is a StatelessWidget', () {
      const list = SettingsList(sections: []);
      expect(list, isA<StatelessWidget>());
    });

    test('stores sections list', () {
      final sections = [
        SettingsSection(tiles: [SettingsTile(title: const Text('T1'))]),
        SettingsSection(tiles: [SettingsTile(title: const Text('T2'))]),
      ];
      final list = SettingsList(sections: sections);
      expect(list.sections, equals(sections));
    });

    test('defaults shrinkWrap to false', () {
      const list = SettingsList(sections: []);
      expect(list.shrinkWrap, isFalse);
    });

    test('can set shrinkWrap to true', () {
      const list = SettingsList(sections: [], shrinkWrap: true);
      expect(list.shrinkWrap, isTrue);
    });

    test('defaults physics to null', () {
      const list = SettingsList(sections: []);
      expect(list.physics, isNull);
    });

    test('stores physics', () {
      const physics = NeverScrollableScrollPhysics();
      const list = SettingsList(sections: [], physics: physics);
      expect(list.physics, equals(physics));
    });

    test('defaults platform to null', () {
      const list = SettingsList(sections: []);
      expect(list.platform, isNull);
    });

    test('stores platform', () {
      const list = SettingsList(sections: [], platform: DevicePlatform.android);
      expect(list.platform, equals(DevicePlatform.android));
    });

    test('defaults contentPadding to null', () {
      const list = SettingsList(sections: []);
      expect(list.contentPadding, isNull);
    });

    test('stores contentPadding', () {
      const padding = EdgeInsets.all(20);
      const list = SettingsList(sections: [], contentPadding: padding);
      expect(list.contentPadding, equals(padding));
    });

    test('stores key', () {
      final key = UniqueKey();
      final list = SettingsList(sections: const [], key: key);
      expect(list.key, equals(key));
    });

    testWidgets('builds with empty sections', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SettingsList(sections: [])),
        ),
      );

      expect(find.byType(SettingsList), findsOneWidget);
    });

    testWidgets('builds with single section', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsList(
              sections: [
                SettingsSection(
                  title: const Text('Section 1'),
                  tiles: [SettingsTile(title: const Text('Tile 1'))],
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Section 1'), findsOneWidget);
      expect(find.text('Tile 1'), findsOneWidget);
    });

    testWidgets('builds with multiple sections', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsList(
              sections: [
                SettingsSection(
                  title: const Text('Section 1'),
                  tiles: [SettingsTile(title: const Text('T1'))],
                ),
                SettingsSection(
                  title: const Text('Section 2'),
                  tiles: [SettingsTile(title: const Text('T2'))],
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Section 1'), findsOneWidget);
      expect(find.text('Section 2'), findsOneWidget);
    });

    testWidgets('uses ListView internally', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SettingsList(sections: [])),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('uses LayoutBuilder', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SettingsList(sections: [])),
        ),
      );

      expect(find.byType(LayoutBuilder), findsOneWidget);
    });

    testWidgets('applies custom contentPadding', (tester) async {
      const customPadding = EdgeInsets.all(50);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingsList(sections: [], contentPadding: customPadding),
          ),
        ),
      );

      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.padding, equals(customPadding));
    });

    testWidgets('applies shrinkWrap to ListView', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SettingsList(sections: [], shrinkWrap: true)),
        ),
      );

      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.shrinkWrap, isTrue);
    });

    testWidgets('applies physics to ListView', (tester) async {
      const physics = NeverScrollableScrollPhysics();

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingsList(sections: [], physics: physics),
          ),
        ),
      );

      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.physics, equals(physics));
    });

    testWidgets('builds with android platform', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsList(
              platform: DevicePlatform.android,
              sections: [
                SettingsSection(tiles: [SettingsTile(title: const Text('T'))]),
              ],
            ),
          ),
        ),
      );

      expect(find.text('T'), findsOneWidget);
    });

    testWidgets('builds with iOS platform', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsList(
              platform: DevicePlatform.iOS,
              sections: [
                SettingsSection(tiles: [SettingsTile(title: const Text('T'))]),
              ],
            ),
          ),
        ),
      );

      expect(find.text('T'), findsOneWidget);
    });

    testWidgets('builds with web platform', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsList(
              platform: DevicePlatform.web,
              sections: [
                SettingsSection(tiles: [SettingsTile(title: const Text('T'))]),
              ],
            ),
          ),
        ),
      );

      expect(find.text('T'), findsOneWidget);
    });
  });

  group('calculateDefaultPadding', () {
    test('returns horizontal padding for wide screens on android', () {
      const constraints = BoxConstraints(maxWidth: 1000);
      final padding = SettingsList.calculateDefaultPadding(
        DevicePlatform.android,
        constraints,
      );

      // (1000 - 810) / 2 = 95
      expect(padding.left, equals(95));
      expect(padding.right, equals(95));
      expect(padding.top, equals(0));
      expect(padding.bottom, equals(0));
    });

    test('returns horizontal padding for wide screens on iOS', () {
      const constraints = BoxConstraints(maxWidth: 1000);
      final padding = SettingsList.calculateDefaultPadding(
        DevicePlatform.iOS,
        constraints,
      );

      expect(padding.left, equals(95));
      expect(padding.right, equals(95));
      expect(padding.top, equals(0));
      expect(padding.bottom, equals(0));
    });

    test('returns vertical+horizontal padding for wide screens on web', () {
      const constraints = BoxConstraints(maxWidth: 1000);
      final padding = SettingsList.calculateDefaultPadding(
        DevicePlatform.web,
        constraints,
      );

      expect(padding.left, equals(95));
      expect(padding.right, equals(95));
      expect(padding.top, equals(20));
      expect(padding.bottom, equals(20));
    });

    test('returns zero vertical padding for narrow screens on android', () {
      const constraints = BoxConstraints(maxWidth: 400);
      final padding = SettingsList.calculateDefaultPadding(
        DevicePlatform.android,
        constraints,
      );

      expect(padding.left, equals(0));
      expect(padding.right, equals(0));
      expect(padding.top, equals(0));
      expect(padding.bottom, equals(0));
    });

    test('returns vertical padding for narrow screens on web', () {
      const constraints = BoxConstraints(maxWidth: 400);
      final padding = SettingsList.calculateDefaultPadding(
        DevicePlatform.web,
        constraints,
      );

      expect(padding.left, equals(0));
      expect(padding.right, equals(0));
      expect(padding.top, equals(20));
      expect(padding.bottom, equals(20));
    });

    test('returns vertical padding for narrow screens on custom', () {
      const constraints = BoxConstraints(maxWidth: 400);
      final padding = SettingsList.calculateDefaultPadding(
        DevicePlatform.custom,
        constraints,
      );

      expect(padding.top, equals(20));
      expect(padding.bottom, equals(20));
    });

    test('handles exactly 810 width (boundary case)', () {
      const constraints = BoxConstraints(maxWidth: 810);
      final padding = SettingsList.calculateDefaultPadding(
        DevicePlatform.android,
        constraints,
      );

      // Width not greater than 810, so narrow screen path
      expect(padding.left, equals(0));
      expect(padding.right, equals(0));
    });

    test('handles 811 width (just over boundary)', () {
      const constraints = BoxConstraints(maxWidth: 811);
      final padding = SettingsList.calculateDefaultPadding(
        DevicePlatform.android,
        constraints,
      );

      // Width > 810, so wide screen path: (811 - 810) / 2 = 0.5
      expect(padding.left, equals(0.5));
      expect(padding.right, equals(0.5));
    });

    test('handles linux platform like android', () {
      const constraints = BoxConstraints(maxWidth: 400);
      final padding = SettingsList.calculateDefaultPadding(
        DevicePlatform.linux,
        constraints,
      );

      expect(padding.top, equals(0));
      expect(padding.bottom, equals(0));
    });

    test('handles macOS platform like iOS', () {
      const constraints = BoxConstraints(maxWidth: 400);
      final padding = SettingsList.calculateDefaultPadding(
        DevicePlatform.macOS,
        constraints,
      );

      expect(padding.top, equals(0));
      expect(padding.bottom, equals(0));
    });

    test('handles windows platform like iOS', () {
      const constraints = BoxConstraints(maxWidth: 400);
      final padding = SettingsList.calculateDefaultPadding(
        DevicePlatform.windows,
        constraints,
      );

      expect(padding.top, equals(0));
      expect(padding.bottom, equals(0));
    });

    test('handles fuchsia platform like android', () {
      const constraints = BoxConstraints(maxWidth: 400);
      final padding = SettingsList.calculateDefaultPadding(
        DevicePlatform.fuchsia,
        constraints,
      );

      expect(padding.top, equals(0));
      expect(padding.bottom, equals(0));
    });
  });
}
