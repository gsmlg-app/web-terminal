import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/src/utils/field_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FieldItem', () {
    test('can be const constructed with required child', () {
      const item = FieldItem(child: Text('Test'));
      expect(item, isA<FieldItem>());
    });

    test('extends StatelessWidget', () {
      const item = FieldItem(child: Text('Test'));
      expect(item, isA<StatelessWidget>());
    });

    test('defaults isEnabled to true', () {
      const item = FieldItem(child: Text('Test'));
      expect(item.isEnabled, isTrue);
    });

    test('can set isEnabled to false', () {
      const item = FieldItem(isEnabled: false, child: Text('Test'));
      expect(item.isEnabled, isFalse);
    });

    test('defaults alignment to centerStart', () {
      const item = FieldItem(child: Text('Test'));
      expect(item.alignment, equals(AlignmentDirectional.centerStart));
    });

    test('can set custom alignment', () {
      const item = FieldItem(alignment: Alignment.center, child: Text('Test'));
      expect(item.alignment, equals(Alignment.center));
    });

    test('defaults onTap to null', () {
      const item = FieldItem(child: Text('Test'));
      expect(item.onTap, isNull);
    });

    test('can set onTap callback', () {
      callback() {}
      final item = FieldItem(onTap: callback, child: const Text('Test'));
      expect(item.onTap, equals(callback));
    });

    test('stores child widget', () {
      const childWidget = Text('Child Text');
      const item = FieldItem(child: childWidget);
      expect(item.child, equals(childWidget));
    });

    test('stores key', () {
      final key = UniqueKey();
      final item = FieldItem(key: key, child: const Text('Test'));
      expect(item.key, equals(key));
    });

    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FieldItem(child: Text('Rendered Child'))),
        ),
      );

      expect(find.text('Rendered Child'), findsOneWidget);
    });

    testWidgets('uses Container with minimum height', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FieldItem(child: Text('Test'))),
        ),
      );

      // Find Container inside FieldItem
      final containerFinder = find.descendant(
        of: find.byType(FieldItem),
        matching: find.byType(Container),
      );
      expect(containerFinder, findsOneWidget);

      final container = tester.widget<Container>(containerFinder);
      expect(
        container.constraints?.minHeight,
        equals(kMinInteractiveDimension),
      );
    });

    testWidgets('container uses centerStart alignment', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FieldItem(child: Text('Test'))),
        ),
      );

      final containerFinder = find.descendant(
        of: find.byType(FieldItem),
        matching: find.byType(Container),
      );
      final container = tester.widget<Container>(containerFinder);
      expect(container.alignment, equals(AlignmentDirectional.centerStart));
    });

    testWidgets('renders different child widgets', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const FieldItem(child: Text('Text Child')),
                FieldItem(child: Icon(Icons.star)),
                FieldItem(
                  child: Row(
                    children: const [Icon(Icons.person), Text('Name')],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Text Child'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
    });

    testWidgets('respects isEnabled property', (tester) async {
      // Note: isEnabled doesn't affect rendering directly,
      // but can be used by parent widgets
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                FieldItem(isEnabled: true, child: Text('Enabled')),
                FieldItem(isEnabled: false, child: Text('Disabled')),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Enabled'), findsOneWidget);
      expect(find.text('Disabled'), findsOneWidget);
    });
  });

  group('FieldItemBuilder typedef', () {
    test('can create a FieldItemBuilder function', () {
      FieldItem builder(BuildContext context, String value) {
        return FieldItem(child: Text(value));
      }

      // Verify the function signature matches
      final FieldItemBuilder<String> typedBuilder = builder;
      expect(typedBuilder, isNotNull);
    });

    testWidgets('FieldItemBuilder produces correct FieldItem', (tester) async {
      FieldItem builder(BuildContext context, String value) {
        return FieldItem(
          isEnabled: value != 'disabled',
          child: Text('Value: $value'),
        );
      }

      late FieldItem builtItem;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                builtItem = builder(context, 'test');
                return builtItem;
              },
            ),
          ),
        ),
      );

      expect(find.text('Value: test'), findsOneWidget);
      expect(builtItem.isEnabled, isTrue);
    });
  });
}
