import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settings_ui/src/sections/abstract_settings_section.dart';
import 'package:settings_ui/src/sections/custom_settings_section.dart';
import 'package:settings_ui/src/tiles/abstract_settings_tile.dart';
import 'package:settings_ui/src/tiles/custom_settings_tile.dart';

void main() {
  group('AbstractSettingsTile', () {
    test('is an abstract class extending StatelessWidget', () {
      // Create a concrete implementation to test the abstract class
      const tile = _TestSettingsTile();
      expect(tile, isA<StatelessWidget>());
      expect(tile, isA<AbstractSettingsTile>());
    });

    test('can have a key', () {
      final key = UniqueKey();
      final tile = _TestSettingsTile(key: key);
      expect(tile.key, equals(key));
    });
  });

  group('AbstractSettingsSection', () {
    test('is an abstract class extending StatelessWidget', () {
      // Create a concrete implementation to test the abstract class
      const section = _TestSettingsSection();
      expect(section, isA<StatelessWidget>());
      expect(section, isA<AbstractSettingsSection>());
    });

    test('can have a key', () {
      final key = UniqueKey();
      final section = _TestSettingsSection(key: key);
      expect(section.key, equals(key));
    });
  });

  group('CustomSettingsTile', () {
    test('extends AbstractSettingsTile', () {
      const tile = CustomSettingsTile(child: Text('Custom'));
      expect(tile, isA<AbstractSettingsTile>());
    });

    test('extends StatelessWidget', () {
      const tile = CustomSettingsTile(child: Text('Custom'));
      expect(tile, isA<StatelessWidget>());
    });

    test('can be const constructed', () {
      const tile = CustomSettingsTile(child: Text('Custom'));
      expect(tile, isA<CustomSettingsTile>());
    });

    test('stores child widget', () {
      const childWidget = Text('My Child');
      const tile = CustomSettingsTile(child: childWidget);
      expect(tile.child, equals(childWidget));
    });

    test('stores key', () {
      final key = UniqueKey();
      final tile = CustomSettingsTile(child: const Text('C'), key: key);
      expect(tile.key, equals(key));
    });

    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CustomSettingsTile(child: Text('Custom Child'))),
        ),
      );

      expect(find.text('Custom Child'), findsOneWidget);
    });

    testWidgets('renders complex child widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomSettingsTile(
              child: Container(
                color: Colors.blue,
                child: const Column(children: [Text('Row 1'), Text('Row 2')]),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Row 1'), findsOneWidget);
      expect(find.text('Row 2'), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('build returns child directly', (tester) async {
      const childWidget = Text('Direct Child');
      const tile = CustomSettingsTile(child: childWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final built = tile.build(context);
                expect(built, equals(childWidget));
                return built;
              },
            ),
          ),
        ),
      );
    });
  });

  group('CustomSettingsSection', () {
    test('extends AbstractSettingsSection', () {
      const section = CustomSettingsSection(child: Text('Custom'));
      expect(section, isA<AbstractSettingsSection>());
    });

    test('extends StatelessWidget', () {
      const section = CustomSettingsSection(child: Text('Custom'));
      expect(section, isA<StatelessWidget>());
    });

    test('can be const constructed', () {
      const section = CustomSettingsSection(child: Text('Custom'));
      expect(section, isA<CustomSettingsSection>());
    });

    test('stores child widget', () {
      const childWidget = Text('My Section Child');
      const section = CustomSettingsSection(child: childWidget);
      expect(section.child, equals(childWidget));
    });

    test('stores key', () {
      final key = UniqueKey();
      final section = CustomSettingsSection(child: const Text('C'), key: key);
      expect(section.key, equals(key));
    });

    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomSettingsSection(child: Text('Section Content')),
          ),
        ),
      );

      expect(find.text('Section Content'), findsOneWidget);
    });

    testWidgets('renders complex child widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomSettingsSection(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: const ListTile(
                  title: Text('Title'),
                  subtitle: Text('Subtitle'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Subtitle'), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('build returns child directly', (tester) async {
      const childWidget = Text('Direct Section Child');
      const section = CustomSettingsSection(child: childWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final built = section.build(context);
                expect(built, equals(childWidget));
                return built;
              },
            ),
          ),
        ),
      );
    });
  });

  group('Integration', () {
    testWidgets('CustomSettingsTile works in SettingsSection context', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CustomSettingsTile(child: Text('Custom Tile 1')),
                CustomSettingsTile(child: Text('Custom Tile 2')),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Custom Tile 1'), findsOneWidget);
      expect(find.text('Custom Tile 2'), findsOneWidget);
    });

    testWidgets('CustomSettingsSection works alongside other sections', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CustomSettingsSection(child: Text('Custom Section 1')),
                CustomSettingsSection(child: Text('Custom Section 2')),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Custom Section 1'), findsOneWidget);
      expect(find.text('Custom Section 2'), findsOneWidget);
    });
  });
}

// Test implementations for abstract classes
class _TestSettingsTile extends AbstractSettingsTile {
  const _TestSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

class _TestSettingsSection extends AbstractSettingsSection {
  const _TestSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
