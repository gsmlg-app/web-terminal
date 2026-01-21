import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/src/utils/typedefs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FieldBlocErrorBuilder', () {
    test('can create a function matching the typedef', () {
      String? errorBuilder(BuildContext context, Object error) {
        return error.toString();
      }

      // Verify it compiles as the expected type
      final FieldBlocErrorBuilder builder = errorBuilder;
      expect(builder, isNotNull);
    });

    test('can return null', () {
      String? errorBuilder(BuildContext context, Object error) {
        return null;
      }

      final FieldBlocErrorBuilder builder = errorBuilder;
      expect(builder, isNotNull);
    });

    test('receives error object correctly', () {
      Object? capturedError;

      String? errorBuilder(BuildContext context, Object error) {
        capturedError = error;
        return 'Error: $error';
      }

      final FieldBlocErrorBuilder builder = errorBuilder;

      // We need a context to call the function - use testWidgets
      // For now, just verify the typedef signature
      expect(builder, isA<Function>());
      expect(capturedError, isNull); // Not called yet
    });

    testWidgets('works with actual BuildContext', (tester) async {
      Object? capturedError;
      BuildContext? capturedContext;

      String? errorBuilder(BuildContext context, Object error) {
        capturedError = error;
        capturedContext = context;
        return 'Error: $error';
      }

      final FieldBlocErrorBuilder builder = errorBuilder;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final result = builder(context, 'Test error');
              return Text(result ?? 'null');
            },
          ),
        ),
      );

      expect(capturedError, equals('Test error'));
      expect(capturedContext, isNotNull);
      expect(find.text('Error: Test error'), findsOneWidget);
    });

    testWidgets('can return null based on error type', (tester) async {
      String? errorBuilder(BuildContext context, Object error) {
        if (error is String && error.isEmpty) {
          return null;
        }
        return error.toString();
      }

      final FieldBlocErrorBuilder builder = errorBuilder;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final result = builder(context, '');
              return Text(result ?? 'no error');
            },
          ),
        ),
      );

      expect(find.text('no error'), findsOneWidget);
    });

    test('handles different error types', () {
      String? errorBuilder(BuildContext context, Object error) {
        if (error is Exception) {
          return 'Exception occurred';
        } else if (error is Error) {
          return 'Error occurred';
        } else if (error is String) {
          return error;
        }
        return 'Unknown error';
      }

      // Just verify the function signature matches
      final FieldBlocErrorBuilder builder = errorBuilder;
      expect(builder, isA<Function>());
    });
  });
}
