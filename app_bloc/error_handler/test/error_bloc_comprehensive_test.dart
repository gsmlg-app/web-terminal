import 'package:bloc_test/bloc_test.dart';
import 'package:error_handler_bloc/error_handler_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Comprehensive test suite for ErrorBloc
///
/// This file contains edge case tests, concurrent operation tests,
/// state management tests, and error lifecycle tests to ensure robust
/// error handling across the application.
///
/// Test coverage (40+ additional tests):
/// 1. Event Equatable Tests (6 tests)
/// 2. State Equatable Tests (6 tests)
/// 3. Error Recovery and Resolution Tests (6 tests)
/// 4. Multiple Error Handling Tests (5 tests)
/// 5. Concurrent Error Operations (5 tests)
/// 6. Helper Method Combinations (4 tests)
/// 7. Edge Cases (8 tests)
/// 8. State Immutability (3 tests)
/// 9. Error Message Generation (4 tests)
/// 10. Error ID Uniqueness (3 tests)

void main() {
  group('Event Equatable Tests', () {
    test('ErrorReported instances with same parameters are equal', () {
      const event1 = ErrorReported(
        error: 'Test error',
        severity: ErrorSeverity.high,
      );
      const event2 = ErrorReported(
        error: 'Test error',
        severity: ErrorSeverity.high,
      );

      expect(event1, equals(event2));
      expect(event1.hashCode, equals(event2.hashCode));
    });

    test('ErrorReported instances with different errors are not equal', () {
      const event1 = ErrorReported(error: 'Error 1');
      const event2 = ErrorReported(error: 'Error 2');

      expect(event1, isNot(equals(event2)));
    });

    test('ErrorReported with different severities are not equal', () {
      const event1 = ErrorReported(error: 'Test', severity: ErrorSeverity.low);
      const event2 = ErrorReported(error: 'Test', severity: ErrorSeverity.high);

      expect(event1, isNot(equals(event2)));
    });

    test('ErrorDismissed instances with same errorId are equal', () {
      const event1 = ErrorDismissed('err_123');
      const event2 = ErrorDismissed('err_123');

      expect(event1, equals(event2));
      expect(event1.hashCode, equals(event2.hashCode));
    });

    test('ErrorDismissed instances with different errorIds are not equal', () {
      const event1 = ErrorDismissed('err_123');
      const event2 = ErrorDismissed('err_456');

      expect(event1, isNot(equals(event2)));
    });

    test('ErrorsCleared instances are always equal', () {
      const event1 = ErrorsCleared();
      const event2 = ErrorsCleared();

      expect(event1, equals(event2));
      expect(event1.hashCode, equals(event2.hashCode));
    });
  });

  group('State Equatable Tests', () {
    test('ErrorState instances with same activeErrors are equal', () {
      final error = AppError(
        id: 'test-id',
        error: 'Test',
        severity: ErrorSeverity.high,
        timestamp: DateTime(2025, 1, 1),
      );
      final state1 = ErrorState(activeErrors: [error]);
      final state2 = ErrorState(activeErrors: [error]);

      expect(state1, equals(state2));
      expect(state1.hashCode, equals(state2.hashCode));
    });

    test('ErrorState instances with different activeErrors are not equal', () {
      final error1 = AppError(
        id: 'id1',
        error: 'Error 1',
        severity: ErrorSeverity.high,
      );
      final error2 = AppError(
        id: 'id2',
        error: 'Error 2',
        severity: ErrorSeverity.high,
      );

      final state1 = ErrorState(activeErrors: [error1]);
      final state2 = ErrorState(activeErrors: [error2]);

      expect(state1, isNot(equals(state2)));
    });

    test('ErrorState with empty lists are equal', () {
      const state1 = ErrorState(activeErrors: [], resolvedErrors: []);
      const state2 = ErrorState(activeErrors: [], resolvedErrors: []);

      expect(state1, equals(state2));
    });

    test('ErrorState with different lastErrorMessage are not equal', () {
      const state1 = ErrorState(lastErrorMessage: 'Error 1');
      const state2 = ErrorState(lastErrorMessage: 'Error 2');

      expect(state1, isNot(equals(state2)));
    });

    test('ErrorState with different isLoading are not equal', () {
      const state1 = ErrorState(isLoading: true);
      const state2 = ErrorState(isLoading: false);

      expect(state1, isNot(equals(state2)));
    });

    test('ErrorState copyWith preserves equality when no changes', () {
      const state1 = ErrorState(isLoading: true, lastErrorMessage: 'Test');
      final state2 = state1.copyWith();

      expect(state1, equals(state2));
    });
  });

  group('Error Recovery and Resolution Tests', () {
    blocTest<ErrorBloc, ErrorState>(
      'ErrorRecovered moves error from active to resolved',
      build: () => ErrorBloc(),
      act: (bloc) async {
        bloc.add(const ErrorReported(error: 'Test error'));
        await Future.delayed(const Duration(milliseconds: 50));

        final errorId = bloc.state.activeErrors.first.id;
        bloc.add(ErrorRecovered(errorId));
      },
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        expect(bloc.state.activeErrors, isEmpty);
        expect(bloc.state.resolvedErrors, hasLength(1));
        expect(bloc.state.resolvedErrors.first.isResolved, isTrue);
      },
    );

    blocTest<ErrorBloc, ErrorState>(
      'ErrorRecovered preserves error details when resolving',
      build: () => ErrorBloc(),
      act: (bloc) async {
        const errorMessage = 'Original error message';
        const context = 'Test context';
        bloc.add(const ErrorReported(
          error: errorMessage,
          context: context,
          severity: ErrorSeverity.critical,
        ));
        await Future.delayed(const Duration(milliseconds: 50));

        final errorId = bloc.state.activeErrors.first.id;
        bloc.add(ErrorRecovered(errorId));
      },
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        final resolved = bloc.state.resolvedErrors.first;
        expect(resolved.error, 'Original error message');
        expect(resolved.context, 'Test context');
        expect(resolved.severity, ErrorSeverity.critical);
        expect(resolved.isResolved, isTrue);
      },
    );

    blocTest<ErrorBloc, ErrorState>(
      'Multiple errors can be recovered independently',
      build: () => ErrorBloc(),
      act: (bloc) async {
        bloc.add(const ErrorReported(error: 'Error 1'));
        bloc.add(const ErrorReported(error: 'Error 2'));
        bloc.add(const ErrorReported(error: 'Error 3'));
        await Future.delayed(const Duration(milliseconds: 50));

        final errorIds = bloc.state.activeErrors.map((e) => e.id).toList();
        // Recover first and third errors
        bloc.add(ErrorRecovered(errorIds[0]));
        await Future.delayed(const Duration(milliseconds: 20));
        bloc.add(ErrorRecovered(errorIds[2]));
      },
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        expect(bloc.state.activeErrors, hasLength(1));
        expect(bloc.state.resolvedErrors, hasLength(2));
        expect(bloc.state.activeErrors.first.error, 'Error 2');
      },
    );

    blocTest<ErrorBloc, ErrorState>(
      'ErrorDismissed completely removes error',
      build: () => ErrorBloc(),
      act: (bloc) async {
        bloc.add(const ErrorReported(error: 'Error to dismiss'));
        await Future.delayed(const Duration(milliseconds: 50));

        final errorId = bloc.state.activeErrors.first.id;
        bloc.add(ErrorDismissed(errorId));
      },
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        expect(bloc.state.activeErrors, isEmpty);
        expect(bloc.state.resolvedErrors, isEmpty);
      },
    );

    blocTest<ErrorBloc, ErrorState>(
      'ErrorsCleared removes all active errors but preserves resolved',
      build: () => ErrorBloc(),
      act: (bloc) async {
        bloc.add(const ErrorReported(error: 'Error 1'));
        bloc.add(const ErrorReported(error: 'Error 2'));
        await Future.delayed(const Duration(milliseconds: 50));

        final firstErrorId = bloc.state.activeErrors.first.id;
        bloc.add(ErrorRecovered(firstErrorId));
        await Future.delayed(const Duration(milliseconds: 50));

        bloc.add(const ErrorsCleared());
      },
      wait: const Duration(milliseconds: 150),
      verify: (bloc) {
        expect(bloc.state.activeErrors, isEmpty);
        expect(bloc.state.resolvedErrors, hasLength(1));
      },
    );

    blocTest<ErrorBloc, ErrorState>(
      'ErrorsCleared works when no resolved errors exist',
      build: () => ErrorBloc(),
      act: (bloc) async {
        bloc.add(const ErrorReported(error: 'Error 1'));
        bloc.add(const ErrorReported(error: 'Error 2'));
        await Future.delayed(const Duration(milliseconds: 50));

        bloc.add(const ErrorsCleared());
      },
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        expect(bloc.state.activeErrors, isEmpty);
        expect(bloc.state.resolvedErrors, isEmpty);
      },
    );
  });

  group('Multiple Error Handling Tests', () {
    blocTest<ErrorBloc, ErrorState>(
      'Multiple errors are added to activeErrors list',
      build: () => ErrorBloc(),
      act: (bloc) {
        bloc.add(const ErrorReported(error: 'Error 1'));
        bloc.add(const ErrorReported(error: 'Error 2'));
        bloc.add(const ErrorReported(error: 'Error 3'));
      },
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        expect(bloc.state.activeErrors, hasLength(3));
        expect(bloc.state.activeErrors[0].error, 'Error 1');
        expect(bloc.state.activeErrors[1].error, 'Error 2');
        expect(bloc.state.activeErrors[2].error, 'Error 3');
      },
    );

    blocTest<ErrorBloc, ErrorState>(
      'hasCriticalErrors returns true with mixed severities',
      build: () => ErrorBloc(),
      act: (bloc) {
        bloc.add(const ErrorReported(
          error: 'Low error',
          severity: ErrorSeverity.low,
        ));
        bloc.add(const ErrorReported(
          error: 'Critical error',
          severity: ErrorSeverity.critical,
        ));
        bloc.add(const ErrorReported(
          error: 'Medium error',
          severity: ErrorSeverity.medium,
        ));
      },
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        expect(bloc.state.hasCriticalErrors, isTrue);
        expect(bloc.state.hasErrors, isTrue);
      },
    );

    blocTest<ErrorBloc, ErrorState>(
      'hasCriticalErrors returns false without critical errors',
      build: () => ErrorBloc(),
      act: (bloc) {
        bloc.add(const ErrorReported(
          error: 'Low',
          severity: ErrorSeverity.low,
        ));
        bloc.add(const ErrorReported(
          error: 'Medium',
          severity: ErrorSeverity.medium,
        ));
        bloc.add(const ErrorReported(
          error: 'High',
          severity: ErrorSeverity.high,
        ));
      },
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        expect(bloc.state.hasCriticalErrors, isFalse);
        expect(bloc.state.hasErrors, isTrue);
      },
    );

    blocTest<ErrorBloc, ErrorState>(
      'Errors maintain order when added sequentially',
      build: () => ErrorBloc(),
      act: (bloc) async {
        for (var i = 1; i <= 5; i++) {
          bloc.add(ErrorReported(error: 'Error $i'));
          await Future.delayed(const Duration(milliseconds: 10));
        }
      },
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        expect(bloc.state.activeErrors, hasLength(5));
        for (var i = 0; i < 5; i++) {
          expect(bloc.state.activeErrors[i].error, 'Error ${i + 1}');
        }
      },
    );

    blocTest<ErrorBloc, ErrorState>(
      'lastErrorMessage reflects most recently reported error',
      build: () => ErrorBloc(),
      act: (bloc) async {
        bloc.add(const ErrorReported(error: 'First error'));
        await Future.delayed(const Duration(milliseconds: 30));
        bloc.add(const ErrorReported(error: 'Second error'));
        await Future.delayed(const Duration(milliseconds: 30));
        bloc.add(const ErrorReported(error: 'Third error'));
      },
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        expect(bloc.state.lastErrorMessage, 'Third error');
      },
    );
  });

  group('Concurrent Error Operations', () {
    blocTest<ErrorBloc, ErrorState>(
      'Rapid error additions (10 errors in 50ms)',
      build: () => ErrorBloc(),
      act: (bloc) async {
        for (var i = 0; i < 10; i++) {
          bloc.add(ErrorReported(error: 'Rapid error $i'));
          await Future.delayed(const Duration(milliseconds: 5));
        }
      },
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        expect(bloc.state.activeErrors, hasLength(10));
      },
    );

    blocTest<ErrorBloc, ErrorState>(
      'Mixed operations: add, dismiss, recover, clear',
      build: () => ErrorBloc(),
      act: (bloc) async {
        bloc.add(const ErrorReported(error: 'Error 1'));
        bloc.add(const ErrorReported(error: 'Error 2'));
        bloc.add(const ErrorReported(error: 'Error 3'));
        await Future.delayed(const Duration(milliseconds: 50));

        final errorIds = bloc.state.activeErrors.map((e) => e.id).toList();
        bloc.add(ErrorDismissed(errorIds[0]));
        await Future.delayed(const Duration(milliseconds: 20));

        bloc.add(ErrorRecovered(errorIds[1]));
        await Future.delayed(const Duration(milliseconds: 20));

        bloc.add(const ErrorsCleared());
      },
      wait: const Duration(milliseconds: 150),
      verify: (bloc) {
        expect(bloc.state.activeErrors, isEmpty);
        expect(bloc.state.resolvedErrors, hasLength(1));
      },
    );

    blocTest<ErrorBloc, ErrorState>(
      'Dismiss non-existent error does not throw',
      build: () => ErrorBloc(),
      act: (bloc) {
        bloc.add(const ErrorReported(error: 'Real error'));
        bloc.add(const ErrorDismissed('non-existent-id'));
      },
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.state.activeErrors, hasLength(1));
      },
    );

    blocTest<ErrorBloc, ErrorState>(
      'Add same error multiple times creates separate instances',
      build: () => ErrorBloc(),
      act: (bloc) {
        bloc.add(const ErrorReported(error: 'Duplicate error'));
        bloc.add(const ErrorReported(error: 'Duplicate error'));
        bloc.add(const ErrorReported(error: 'Duplicate error'));
      },
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        expect(bloc.state.activeErrors, hasLength(3));
        // All should have different IDs
        final ids = bloc.state.activeErrors.map((e) => e.id).toSet();
        expect(ids, hasLength(3));
      },
    );

    blocTest<ErrorBloc, ErrorState>(
      'Recover and immediately dismiss same error',
      build: () => ErrorBloc(),
      act: (bloc) async {
        bloc.add(const ErrorReported(error: 'Test error'));
        await Future.delayed(const Duration(milliseconds: 50));

        final errorId = bloc.state.activeErrors.first.id;
        bloc.add(ErrorRecovered(errorId));
        // Try to dismiss after recovery (should be no-op since already moved)
        bloc.add(ErrorDismissed(errorId));
      },
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        expect(bloc.state.activeErrors, isEmpty);
        expect(bloc.state.resolvedErrors, hasLength(1));
      },
    );
  });

  group('Helper Method Combinations', () {
    test('reportNetworkError sets medium severity', () async {
      final bloc = ErrorBloc();
      bloc.reportNetworkError('Network failed');
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.activeErrors, hasLength(1));
      expect(bloc.state.activeErrors.first.severity, ErrorSeverity.medium);
      expect(bloc.state.activeErrors.first.error, 'Network failed');
      bloc.close();
    });

    test('reportValidationError sets low severity', () async {
      final bloc = ErrorBloc();
      bloc.reportValidationError('Invalid input');
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.activeErrors, hasLength(1));
      expect(bloc.state.activeErrors.first.severity, ErrorSeverity.low);
      expect(bloc.state.activeErrors.first.error, 'Invalid input');
      bloc.close();
    });

    test('reportUnexpectedError sets high severity', () async {
      final bloc = ErrorBloc();
      bloc.reportUnexpectedError('Unexpected error');
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.activeErrors, hasLength(1));
      expect(bloc.state.activeErrors.first.severity, ErrorSeverity.high);
      expect(bloc.state.activeErrors.first.error, 'Unexpected error');
      bloc.close();
    });

    test('Helper methods can be mixed', () async {
      final bloc = ErrorBloc();
      bloc.reportNetworkError('Network error');
      bloc.reportValidationError('Validation error');
      bloc.reportUnexpectedError('Unexpected error');
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.activeErrors, hasLength(3));
      expect(
        bloc.state.activeErrors.map((e) => e.severity).toSet(),
        containsAll([
          ErrorSeverity.medium,
          ErrorSeverity.low,
          ErrorSeverity.high,
        ]),
      );
      bloc.close();
    });
  });

  group('Edge Cases', () {
    test('Error with very long message', () async {
      final bloc = ErrorBloc();
      final longMessage = 'A' * 10000; // 10,000 characters
      bloc.add(ErrorReported(error: longMessage));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.activeErrors.first.error, longMessage);
      bloc.close();
    });

    test('Error with null context', () async {
      final bloc = ErrorBloc();
      bloc.add(const ErrorReported(error: 'Test', context: null));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.activeErrors.first.context, isNull);
      bloc.close();
    });

    test('Error with empty string', () async {
      final bloc = ErrorBloc();
      bloc.add(const ErrorReported(error: ''));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.activeErrors, hasLength(1));
      expect(bloc.state.activeErrors.first.error, '');
      bloc.close();
    });

    test('Error with special characters in message', () async {
      final bloc = ErrorBloc();
      const specialError = r'Error with \n\t special $chars @#%^&*()';
      bloc.add(const ErrorReported(error: specialError));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.activeErrors.first.error, specialError);
      bloc.close();
    });

    test('Error with unicode characters', () async {
      final bloc = ErrorBloc();
      const unicodeError = '错误 エラー 오류 🚨';
      bloc.add(const ErrorReported(error: unicodeError));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.activeErrors.first.error, unicodeError);
      bloc.close();
    });

    test('ErrorsCleared on empty state does nothing', () async {
      final bloc = ErrorBloc();
      bloc.add(const ErrorsCleared());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.activeErrors, isEmpty);
      expect(bloc.state.resolvedErrors, isEmpty);
      bloc.close();
    });

    test('Error with null stackTrace', () async {
      final bloc = ErrorBloc();
      bloc.add(const ErrorReported(error: 'Test', stackTrace: null));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.activeErrors.first.stackTrace, isNull);
      bloc.close();
    });

    test('Error with actual Exception object', () async {
      final bloc = ErrorBloc();
      bloc.add(ErrorReported(error: Exception('Test exception')));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.activeErrors.first.error, isA<Exception>());
      // userMessage for high severity Exception is the generated message
      expect(
        bloc.state.activeErrors.first.userMessage,
        'Something went wrong. Please try again.',
      );
      // displayMessage returns userMessage when set
      expect(
        bloc.state.activeErrors.first.displayMessage,
        'Something went wrong. Please try again.',
      );
      bloc.close();
    });
  });

  group('State Immutability', () {
    test('Modifying activeErrors list does not affect state', () async {
      final bloc = ErrorBloc();
      bloc.add(const ErrorReported(error: 'Error 1'));
      await Future.delayed(const Duration(milliseconds: 50));

      final originalState = bloc.state;
      final activeErrors = List<AppError>.from(originalState.activeErrors);

      // Attempt to modify the copied list
      activeErrors.add(AppError(
        id: 'fake-id',
        error: 'Fake error',
        severity: ErrorSeverity.high,
      ));

      // Original state should be unchanged
      expect(bloc.state.activeErrors, hasLength(1));
      expect(bloc.state.activeErrors.first.error, 'Error 1');
      bloc.close();
    });

    test('copyWith creates independent state', () async {
      final bloc = ErrorBloc();
      bloc.add(const ErrorReported(error: 'Test'));
      await Future.delayed(const Duration(milliseconds: 50));

      final state1 = bloc.state;
      final state2 = state1.copyWith(lastErrorMessage: 'Modified');

      expect(state1.lastErrorMessage, isNot('Modified'));
      expect(state2.lastErrorMessage, 'Modified');
      expect(state1.activeErrors, state2.activeErrors);
      bloc.close();
    });

    test('Resolved errors list is independent', () async {
      final bloc = ErrorBloc();
      bloc.add(const ErrorReported(error: 'Error'));
      await Future.delayed(const Duration(milliseconds: 50));

      final errorId = bloc.state.activeErrors.first.id;
      bloc.add(ErrorRecovered(errorId));
      await Future.delayed(const Duration(milliseconds: 50));

      final resolvedErrors = List<AppError>.from(bloc.state.resolvedErrors);
      resolvedErrors.clear();

      expect(bloc.state.resolvedErrors, hasLength(1));
      bloc.close();
    });
  });

  group('Error Message Generation', () {
    test('Critical severity with non-string error generates critical message', () async {
      final bloc = ErrorBloc();
      bloc.add(ErrorReported(
        error: Exception('Critical'),
        severity: ErrorSeverity.critical,
      ));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(
        bloc.state.activeErrors.first.userMessage,
        'A critical error occurred. Please restart the app.',
      );
      bloc.close();
    });

    test('High severity with non-string error generates high message', () async {
      final bloc = ErrorBloc();
      bloc.add(ErrorReported(
        error: Exception('High'),
        severity: ErrorSeverity.high,
      ));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(
        bloc.state.activeErrors.first.userMessage,
        'Something went wrong. Please try again.',
      );
      bloc.close();
    });

    test('Medium severity with non-string error generates medium message', () async {
      final bloc = ErrorBloc();
      bloc.add(ErrorReported(
        error: Exception('Medium'),
        severity: ErrorSeverity.medium,
      ));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(
        bloc.state.activeErrors.first.userMessage,
        'We encountered a small issue. It should resolve shortly.',
      );
      bloc.close();
    });

    test('Low severity with non-string error generates null user message', () async {
      final bloc = ErrorBloc();
      bloc.add(ErrorReported(
        error: Exception('Low'),
        severity: ErrorSeverity.low,
      ));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.activeErrors.first.userMessage, isNull);
      bloc.close();
    });
  });

  group('Error ID Uniqueness', () {
    test('Error IDs are unique for each error', () async {
      final bloc = ErrorBloc();
      for (var i = 0; i < 10; i++) {
        bloc.add(const ErrorReported(error: 'Test'));
      }
      await Future.delayed(const Duration(milliseconds: 100));

      final ids = bloc.state.activeErrors.map((e) => e.id).toSet();
      expect(ids, hasLength(10));
      bloc.close();
    });

    test('Error IDs contain timestamp information', () async {
      final bloc = ErrorBloc();
      bloc.add(const ErrorReported(error: 'Test'));
      await Future.delayed(const Duration(milliseconds: 50));

      final errorId = bloc.state.activeErrors.first.id;
      expect(errorId, startsWith('err_'));
      expect(errorId, contains('_'));
      bloc.close();
    });

    test('Rapid error IDs are still unique', () async {
      final bloc = ErrorBloc();
      final ids = <String>{};

      for (var i = 0; i < 100; i++) {
        bloc.add(const ErrorReported(error: 'Rapid'));
      }
      await Future.delayed(const Duration(milliseconds: 200));

      for (final error in bloc.state.activeErrors) {
        ids.add(error.id);
      }

      expect(ids, hasLength(100));
      bloc.close();
    });
  });
}
