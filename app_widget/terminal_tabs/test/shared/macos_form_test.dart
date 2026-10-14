import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_tabs/src/shared/macos_form.dart';

void main() {
  group('MacosFormRow', () {
    // Unit tests don't require widget pumping
    test('has static labelWidth constant of 100.0', () {
      expect(MacosFormRow.labelWidth, equals(100.0));
    });

    test('can be constructed with const', () {
      const row = MacosFormRow(child: Text('Test'));
      expect(row, isA<MacosFormRow>());
    });

    test('can be constructed with key', () {
      const key = Key('form_row');
      const row = MacosFormRow(key: key, child: Text('Test'));
      expect(row.key, equals(key));
    });

    test('stores label property', () {
      const row = MacosFormRow(label: Text('Label'), child: Text('Child'));
      expect(row.label, isNotNull);
    });

    test('stores spaceBetween property', () {
      const row = MacosFormRow(spaceBetween: 12.0, child: Text('Child'));
      expect(row.spaceBetween, equals(12.0));
    });

    test('has default spaceBetween of 8.0', () {
      const row = MacosFormRow(child: Text('Child'));
      expect(row.spaceBetween, equals(8.0));
    });

    test('has null label by default', () {
      const row = MacosFormRow(child: Text('Child'));
      expect(row.label, isNull);
    });

    test('stores child property', () {
      const row = MacosFormRow(child: Text('Child'));
      expect(row.child, isNotNull);
      expect(row.child, isA<Text>());
    });

    // Simple widget tests using CupertinoApp to avoid MacosApp's native features
    testWidgets('renders child widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: MacosFormRow(child: Text('Test Child')),
          ),
        ),
      );

      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('renders label when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: MacosFormRow(label: Text('Label'), child: Text('Child')),
          ),
        ),
      );

      expect(find.text('Label'), findsOneWidget);
      expect(find.text('Child'), findsOneWidget);
    });

    testWidgets('does not render SizedBox spacer when label is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: MacosFormRow(child: Text('Child')),
          ),
        ),
      );

      expect(find.text('Child'), findsOneWidget);
      // When label is null, no SizedBox with width 8.0 is rendered
      final sizedBoxes = find.byType(SizedBox);
      bool hasSpacer = false;
      for (int i = 0; i < tester.widgetList(sizedBoxes).length; i++) {
        final sizedBox = tester.widget<SizedBox>(sizedBoxes.at(i));
        if (sizedBox.width == 8.0) {
          hasSpacer = true;
        }
      }
      expect(hasSpacer, isFalse);
    });

    testWidgets('renders SizedBox spacer when label is provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: MacosFormRow(label: Text('Label'), child: Text('Child')),
          ),
        ),
      );

      // Find SizedBox with width 8.0 (default spaceBetween)
      final sizedBoxes = find.byType(SizedBox);
      bool hasCorrectSpacer = false;
      for (int i = 0; i < tester.widgetList(sizedBoxes).length; i++) {
        final sizedBox = tester.widget<SizedBox>(sizedBoxes.at(i));
        if (sizedBox.width == 8.0) {
          hasCorrectSpacer = true;
        }
      }
      expect(hasCorrectSpacer, isTrue);
    });

    testWidgets('uses custom space between when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: MacosFormRow(
              label: Text('Label'),
              spaceBetween: 16.0,
              child: Text('Child'),
            ),
          ),
        ),
      );

      // Find SizedBox with width 16.0
      final sizedBoxes = find.byType(SizedBox);
      bool hasCorrectSpacer = false;
      for (int i = 0; i < tester.widgetList(sizedBoxes).length; i++) {
        final sizedBox = tester.widget<SizedBox>(sizedBoxes.at(i));
        if (sizedBox.width == 16.0) {
          hasCorrectSpacer = true;
        }
      }
      expect(hasCorrectSpacer, isTrue);
    });

    testWidgets('has padding of 4.0', (WidgetTester tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: MacosFormRow(child: Text('Child')),
          ),
        ),
      );

      // Find the Padding widget that's part of MacosFormRow
      final paddings = tester.widgetList<Padding>(find.byType(Padding));
      bool hasPaddingOf4 = false;
      for (final padding in paddings) {
        if (padding.padding == const EdgeInsets.all(4.0)) {
          hasPaddingOf4 = true;
          break;
        }
      }
      expect(hasPaddingOf4, isTrue);
    });

    testWidgets('uses Row to layout widgets', (WidgetTester tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: MacosFormRow(child: Text('Child')),
          ),
        ),
      );

      expect(find.byType(Row), findsAtLeastNWidgets(1));
    });

    testWidgets('wraps child with Expanded', (WidgetTester tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: MacosFormRow(child: Text('Child')),
          ),
        ),
      );

      expect(find.byType(Expanded), findsOneWidget);
    });

    testWidgets('label is aligned to center right', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: MacosFormRow(label: Text('Label'), child: Text('Child')),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.alignment, equals(Alignment.centerRight));
    });

    testWidgets('label container has width of labelWidth', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: MacosFormRow(label: Text('Label'), child: Text('Child')),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.maxWidth, equals(MacosFormRow.labelWidth));
    });
  });

  group('MacosTextFormRow', () {
    // Unit tests
    test('can be constructed with const', () {
      const row = MacosTextFormRow();
      expect(row, isA<MacosTextFormRow>());
    });

    test('can be constructed with key', () {
      const key = Key('text_form_row');
      const row = MacosTextFormRow(key: key);
      expect(row.key, equals(key));
    });

    test('has null label by default', () {
      const row = MacosTextFormRow();
      expect(row.label, isNull);
    });

    test('has null placeholder by default', () {
      const row = MacosTextFormRow();
      expect(row.placeholder, isNull);
    });

    test('has false obscureText by default', () {
      const row = MacosTextFormRow();
      expect(row.obscureText, isFalse);
    });

    test('has null onChanged by default', () {
      const row = MacosTextFormRow();
      expect(row.onChanged, isNull);
    });

    test('has null controller by default', () {
      const row = MacosTextFormRow();
      expect(row.controller, isNull);
    });

    test('stores label property', () {
      const row = MacosTextFormRow(label: Text('Username'));
      expect(row.label, isNotNull);
    });

    test('stores placeholder property', () {
      const row = MacosTextFormRow(placeholder: 'Enter text');
      expect(row.placeholder, equals('Enter text'));
    });

    test('stores obscureText property', () {
      const row = MacosTextFormRow(obscureText: true);
      expect(row.obscureText, isTrue);
    });

    test('stores onChanged callback', () {
      final row = MacosTextFormRow(onChanged: (value) {});
      expect(row.onChanged, isNotNull);
    });

    test('stores controller', () {
      final controller = TextEditingController();
      final row = MacosTextFormRow(controller: controller);
      expect(row.controller, equals(controller));
    });
  });
}
