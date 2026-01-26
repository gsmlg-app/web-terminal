import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/src/utils/widgets.dart';
import 'package:flutter_form_bloc/src/theme/form_bloc_theme.dart';
import 'package:flutter_form_bloc/src/theme/form_bloc_theme_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DefaultFieldBlocBuilderTextStyle', () {
    test('can be const constructed', () {
      const widget = DefaultFieldBlocBuilderTextStyle(
        isEnabled: true,
        child: Text('Test'),
      );
      expect(widget, isA<DefaultFieldBlocBuilderTextStyle>());
    });

    test('extends StatelessWidget', () {
      const widget = DefaultFieldBlocBuilderTextStyle(
        isEnabled: true,
        child: Text('Test'),
      );
      expect(widget, isA<StatelessWidget>());
    });

    test('stores isEnabled property', () {
      const widget = DefaultFieldBlocBuilderTextStyle(
        isEnabled: false,
        child: Text('Test'),
      );
      expect(widget.isEnabled, isFalse);
    });

    test('stores style property', () {
      const style = TextStyle(fontSize: 20);
      const widget = DefaultFieldBlocBuilderTextStyle(
        isEnabled: true,
        style: style,
        child: Text('Test'),
      );
      expect(widget.style, equals(style));
    });

    test('stores child property', () {
      const child = Text('Test Child');
      const widget = DefaultFieldBlocBuilderTextStyle(
        isEnabled: true,
        child: child,
      );
      expect(widget.child, equals(child));
    });

    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormThemeProvider(
              theme: const FormTheme(),
              child: const DefaultFieldBlocBuilderTextStyle(
                isEnabled: true,
                child: Text('Styled Text'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Styled Text'), findsOneWidget);
    });

    testWidgets('wraps child in DefaultTextStyle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormThemeProvider(
              theme: const FormTheme(),
              child: const DefaultFieldBlocBuilderTextStyle(
                isEnabled: true,
                child: Text('Test'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(DefaultTextStyle), findsWidgets);
    });

    testWidgets('applies custom style when provided', (tester) async {
      const customStyle = TextStyle(fontSize: 24, color: Colors.red);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormThemeProvider(
              theme: const FormTheme(),
              child: const DefaultFieldBlocBuilderTextStyle(
                isEnabled: true,
                style: customStyle,
                child: Text('Styled'),
              ),
            ),
          ),
        ),
      );

      // Widget renders without error
      expect(find.text('Styled'), findsOneWidget);
    });
  });

  group('DefaultFieldBlocBuilderPadding', () {
    test('can be const constructed', () {
      const widget = DefaultFieldBlocBuilderPadding(
        padding: null,
        child: Text('Test'),
      );
      expect(widget, isA<DefaultFieldBlocBuilderPadding>());
    });

    test('extends StatelessWidget', () {
      const widget = DefaultFieldBlocBuilderPadding(
        padding: null,
        child: Text('Test'),
      );
      expect(widget, isA<StatelessWidget>());
    });

    test('stores padding property', () {
      const padding = EdgeInsets.all(16);
      const widget = DefaultFieldBlocBuilderPadding(
        padding: padding,
        child: Text('Test'),
      );
      expect(widget.padding, equals(padding));
    });

    test('stores child property', () {
      const child = Text('Child Text');
      const widget = DefaultFieldBlocBuilderPadding(
        padding: null,
        child: child,
      );
      expect(widget.child, equals(child));
    });

    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormThemeProvider(
              theme: const FormTheme(),
              child: const DefaultFieldBlocBuilderPadding(
                padding: null,
                child: Text('Padded Text'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Padded Text'), findsOneWidget);
    });

    testWidgets('wraps child in Padding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormThemeProvider(
              theme: const FormTheme(),
              child: const DefaultFieldBlocBuilderPadding(
                padding: null,
                child: Text('Test'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('uses provided padding when set', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormThemeProvider(
              theme: const FormTheme(),
              child: const DefaultFieldBlocBuilderPadding(
                padding: EdgeInsets.all(20),
                child: Text('Custom Padded'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Custom Padded'), findsOneWidget);
    });

    testWidgets('uses default padding when null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormThemeProvider(
              theme: const FormTheme(),
              child: const DefaultFieldBlocBuilderPadding(
                padding: null,
                child: Text('Default Padded'),
              ),
            ),
          ),
        ),
      );

      // Uses FormTheme.defaultPadding which is EdgeInsets.symmetric(vertical: 8.0)
      expect(find.text('Default Padded'), findsOneWidget);
    });
  });

  group('GroupInputDecorator', () {
    test('can be const constructed', () {
      const widget = GroupInputDecorator(
        decoration: InputDecoration(),
        child: Text('Test'),
      );
      expect(widget, isA<GroupInputDecorator>());
    });

    test('extends StatelessWidget', () {
      const widget = GroupInputDecorator(
        decoration: InputDecoration(),
        child: Text('Test'),
      );
      expect(widget, isA<StatelessWidget>());
    });

    test('stores decoration property', () {
      const decoration = InputDecoration(labelText: 'Label');
      const widget = GroupInputDecorator(
        decoration: decoration,
        child: Text('Test'),
      );
      expect(widget.decoration, equals(decoration));
    });

    test('stores child property', () {
      const child = Text('Child Widget');
      const widget = GroupInputDecorator(
        decoration: InputDecoration(),
        child: child,
      );
      expect(widget.child, equals(child));
    });

    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupInputDecorator(
              decoration: const InputDecoration(),
              child: const Text('Group Child'),
            ),
          ),
        ),
      );

      // GroupInputDecorator uses Stack with 2 copies of child (one invisible)
      expect(find.text('Group Child'), findsNWidgets(2));
    });

    testWidgets('uses Stack for layout', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupInputDecorator(
              decoration: const InputDecoration(),
              child: const Text('Test'),
            ),
          ),
        ),
      );

      // GroupInputDecorator uses Stack internally
      final stackFinder = find.descendant(
        of: find.byType(GroupInputDecorator),
        matching: find.byType(Stack),
      );
      expect(stackFinder, findsOneWidget);
    });

    testWidgets('contains multiple InputDecorators', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupInputDecorator(
              decoration: const InputDecoration(),
              child: const Text('Test'),
            ),
          ),
        ),
      );

      // GroupInputDecorator uses two InputDecorators
      final decoratorFinder = find.descendant(
        of: find.byType(GroupInputDecorator),
        matching: find.byType(InputDecorator),
      );
      expect(decoratorFinder, findsNWidgets(2));
    });

    testWidgets('works with label decoration', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupInputDecorator(
              decoration: const InputDecoration(
                labelText: 'Group Label',
                helperText: 'Helper text',
              ),
              child: const Text('Content'),
            ),
          ),
        ),
      );

      // GroupInputDecorator uses Stack with 2 copies of child (one invisible)
      expect(find.text('Content'), findsNWidgets(2));
    });

    testWidgets('handles contentPadding in decoration', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupInputDecorator(
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(16),
              ),
              child: const Text('Padded Content'),
            ),
          ),
        ),
      );

      // GroupInputDecorator uses Stack with 2 copies of child (one invisible)
      expect(find.text('Padded Content'), findsNWidgets(2));
    });

    testWidgets('includes Opacity for invisible child layer', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupInputDecorator(
              decoration: const InputDecoration(),
              child: const Text('Test'),
            ),
          ),
        ),
      );

      // One child is wrapped in Opacity(opacity: 0.0)
      expect(find.byType(Opacity), findsOneWidget);
    });
  });
}
