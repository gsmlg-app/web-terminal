import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_logging/src/error_display.dart';

void main() {
  group('ErrorSeverity', () {
    test('has correct values', () {
      expect(ErrorSeverity.values.length, equals(4));
      expect(ErrorSeverity.low, isNotNull);
      expect(ErrorSeverity.medium, isNotNull);
      expect(ErrorSeverity.high, isNotNull);
      expect(ErrorSeverity.critical, isNotNull);
    });

    test('has correct index order', () {
      expect(ErrorSeverity.low.index, equals(0));
      expect(ErrorSeverity.medium.index, equals(1));
      expect(ErrorSeverity.high.index, equals(2));
      expect(ErrorSeverity.critical.index, equals(3));
    });

    test('has correct name values', () {
      expect(ErrorSeverity.low.name, equals('low'));
      expect(ErrorSeverity.medium.name, equals('medium'));
      expect(ErrorSeverity.high.name, equals('high'));
      expect(ErrorSeverity.critical.name, equals('critical'));
    });
  });

  group('ErrorDisplay', () {
    Widget buildTestApp({required Widget child}) {
      return MaterialApp(
        home: Scaffold(body: Builder(builder: (context) => child)),
      );
    }

    group('showError with low severity', () {
      testWidgets('shows snackbar with message', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestApp(
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ErrorDisplay.showError(
                    context,
                    'Low severity error',
                    severity: ErrorSeverity.low,
                  );
                },
                child: const Text('Show Error'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Error'));
        await tester.pump();

        expect(find.text('Low severity error'), findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);
      });

      testWidgets('shows DISMISS action when no onRetry', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          buildTestApp(
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ErrorDisplay.showError(
                    context,
                    'Test error',
                    severity: ErrorSeverity.low,
                  );
                },
                child: const Text('Show Error'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Error'));
        await tester.pump();

        expect(find.text('DISMISS'), findsOneWidget);
      });

      testWidgets('shows RETRY action when onRetry provided', (
        WidgetTester tester,
      ) async {
        bool retryCalled = false;

        await tester.pumpWidget(
          buildTestApp(
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ErrorDisplay.showError(
                    context,
                    'Test error',
                    severity: ErrorSeverity.low,
                    onRetry: () => retryCalled = true,
                  );
                },
                child: const Text('Show Error'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Error'));
        await tester.pumpAndSettle();

        expect(find.text('RETRY'), findsOneWidget);

        await tester.tap(find.text('RETRY'));
        await tester.pump();
        expect(retryCalled, isTrue);
      });
    });

    group('showError with medium severity', () {
      testWidgets('shows snackbar with message', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestApp(
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ErrorDisplay.showError(
                    context,
                    'Medium severity error',
                    severity: ErrorSeverity.medium,
                  );
                },
                child: const Text('Show Error'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Error'));
        await tester.pump();

        expect(find.text('Medium severity error'), findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);
      });
    });

    group('showError with high severity', () {
      testWidgets('shows dialog with message', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestApp(
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ErrorDisplay.showError(
                    context,
                    'High severity error',
                    severity: ErrorSeverity.high,
                  );
                },
                child: const Text('Show Error'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Error'));
        await tester.pump();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Error'), findsOneWidget);
        expect(find.text('High severity error'), findsOneWidget);
      });

      testWidgets('shows OK button', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestApp(
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ErrorDisplay.showError(
                    context,
                    'Test error',
                    severity: ErrorSeverity.high,
                  );
                },
                child: const Text('Show Error'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Error'));
        await tester.pump();

        expect(find.text('OK'), findsOneWidget);
      });

      testWidgets('shows RETRY button when onRetry provided', (
        WidgetTester tester,
      ) async {
        bool retryCalled = false;

        await tester.pumpWidget(
          buildTestApp(
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ErrorDisplay.showError(
                    context,
                    'Test error',
                    severity: ErrorSeverity.high,
                    onRetry: () => retryCalled = true,
                  );
                },
                child: const Text('Show Error'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Error'));
        await tester.pump();

        expect(find.text('RETRY'), findsOneWidget);

        await tester.tap(find.text('RETRY'));
        expect(retryCalled, isTrue);
      });

      testWidgets('closes dialog when OK pressed', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          buildTestApp(
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ErrorDisplay.showError(
                    context,
                    'Test error',
                    severity: ErrorSeverity.high,
                  );
                },
                child: const Text('Show Error'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Error'));
        await tester.pump();

        expect(find.byType(AlertDialog), findsOneWidget);

        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
      });
    });

    group('showError with critical severity', () {
      testWidgets('shows dialog with error icon', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestApp(
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ErrorDisplay.showError(
                    context,
                    'Critical error',
                    severity: ErrorSeverity.critical,
                  );
                },
                child: const Text('Show Error'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Error'));
        await tester.pump();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.byIcon(Icons.error), findsOneWidget);
        expect(find.text('Critical Error'), findsOneWidget);
      });

      testWidgets('shows restart message', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestApp(
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ErrorDisplay.showError(
                    context,
                    'Critical error',
                    severity: ErrorSeverity.critical,
                  );
                },
                child: const Text('Show Error'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Error'));
        await tester.pump();

        expect(
          find.text('The app needs to restart to recover.'),
          findsOneWidget,
        );
      });

      testWidgets('shows RESTART APP button when onRetry provided', (
        WidgetTester tester,
      ) async {
        bool retryCalled = false;

        await tester.pumpWidget(
          buildTestApp(
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ErrorDisplay.showError(
                    context,
                    'Critical error',
                    severity: ErrorSeverity.critical,
                    onRetry: () => retryCalled = true,
                  );
                },
                child: const Text('Show Error'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Error'));
        await tester.pump();

        expect(find.text('RESTART APP'), findsOneWidget);

        await tester.tap(find.text('RESTART APP'));
        expect(retryCalled, isTrue);
      });
    });

    group('default severity', () {
      testWidgets('uses medium severity by default', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          buildTestApp(
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ErrorDisplay.showError(context, 'Default error');
                },
                child: const Text('Show Error'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Error'));
        await tester.pump();

        // Medium severity shows snackbar
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Default error'), findsOneWidget);
      });
    });
  });
}
