import 'package:bloc_test/bloc_test.dart';
import 'package:error_handler_bloc/error_handler_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ErrorSeverity', () {
    test('has all expected values', () {
      expect(ErrorSeverity.values, hasLength(4));
      expect(ErrorSeverity.values, contains(ErrorSeverity.low));
      expect(ErrorSeverity.values, contains(ErrorSeverity.medium));
      expect(ErrorSeverity.values, contains(ErrorSeverity.high));
      expect(ErrorSeverity.values, contains(ErrorSeverity.critical));
    });
  });

  group('AppError', () {
    test('creates with required parameters', () {
      final error = AppError(
        id: 'test-id',
        error: 'Test error',
        severity: ErrorSeverity.high,
      );

      expect(error.id, 'test-id');
      expect(error.error, 'Test error');
      expect(error.severity, ErrorSeverity.high);
      expect(error.isResolved, false);
      expect(error.timestamp, isNotNull);
    });

    test('creates with all parameters', () {
      final stackTrace = StackTrace.current;
      final timestamp = DateTime(2025, 1, 1);
      final error = AppError(
        id: 'test-id',
        error: Exception('Test exception'),
        stackTrace: stackTrace,
        context: 'Test context',
        severity: ErrorSeverity.critical,
        timestamp: timestamp,
        isResolved: true,
        userMessage: 'User message',
      );

      expect(error.stackTrace, stackTrace);
      expect(error.context, 'Test context');
      expect(error.timestamp, timestamp);
      expect(error.isResolved, true);
      expect(error.userMessage, 'User message');
    });

    test('displayMessage returns userMessage when set', () {
      final error = AppError(
        id: 'test-id',
        error: 'Internal error',
        severity: ErrorSeverity.high,
        userMessage: 'User-friendly message',
      );

      expect(error.displayMessage, 'User-friendly message');
    });

    test('displayMessage returns error string when userMessage is null', () {
      final error = AppError(
        id: 'test-id',
        error: 'Error string',
        severity: ErrorSeverity.high,
      );

      expect(error.displayMessage, 'Error string');
    });

    test('displayMessage returns exception string for Exception', () {
      final error = AppError(
        id: 'test-id',
        error: Exception('Test exception'),
        severity: ErrorSeverity.high,
      );

      expect(error.displayMessage, contains('Test exception'));
    });

    test('displayMessage returns default for non-string, non-exception error', () {
      final error = AppError(
        id: 'test-id',
        error: 42,
        severity: ErrorSeverity.high,
      );

      expect(error.displayMessage, 'An unexpected error occurred');
    });

    test('copyWith creates new instance with updated values', () {
      final original = AppError(
        id: 'test-id',
        error: 'Original error',
        severity: ErrorSeverity.low,
        isResolved: false,
      );

      final updated = original.copyWith(
        isResolved: true,
        severity: ErrorSeverity.high,
      );

      expect(updated.id, original.id);
      expect(updated.error, original.error);
      expect(updated.isResolved, true);
      expect(updated.severity, ErrorSeverity.high);
      expect(original.isResolved, false);
    });

    test('equality based on props', () {
      final timestamp = DateTime.now();
      final error1 = AppError(
        id: 'test-id',
        error: 'Test error',
        severity: ErrorSeverity.high,
        timestamp: timestamp,
      );
      final error2 = AppError(
        id: 'test-id',
        error: 'Test error',
        severity: ErrorSeverity.high,
        timestamp: timestamp,
      );

      expect(error1, equals(error2));
    });
  });

  group('ErrorState', () {
    test('creates with default values', () {
      const state = ErrorState();

      expect(state.activeErrors, isEmpty);
      expect(state.resolvedErrors, isEmpty);
      expect(state.isLoading, false);
      expect(state.lastErrorMessage, isNull);
    });

    test('hasErrors returns true when activeErrors is not empty', () {
      final error = AppError(
        id: 'test-id',
        error: 'Test',
        severity: ErrorSeverity.high,
      );
      final state = ErrorState(activeErrors: [error]);

      expect(state.hasErrors, true);
    });

    test('hasErrors returns false when activeErrors is empty', () {
      const state = ErrorState();
      expect(state.hasErrors, false);
    });

    test('hasCriticalErrors returns true for critical errors', () {
      final criticalError = AppError(
        id: 'critical',
        error: 'Critical',
        severity: ErrorSeverity.critical,
      );
      final state = ErrorState(activeErrors: [criticalError]);

      expect(state.hasCriticalErrors, true);
    });

    test('hasCriticalErrors returns false for non-critical errors', () {
      final highError = AppError(
        id: 'high',
        error: 'High',
        severity: ErrorSeverity.high,
      );
      final state = ErrorState(activeErrors: [highError]);

      expect(state.hasCriticalErrors, false);
    });

    test('copyWith creates new instance with updated values', () {
      const original = ErrorState(isLoading: false);
      final updated = original.copyWith(
        isLoading: true,
        lastErrorMessage: 'Error message',
      );

      expect(updated.isLoading, true);
      expect(updated.lastErrorMessage, 'Error message');
      expect(original.isLoading, false);
    });
  });

  group('ErrorEvent', () {
    test('ErrorReported creates with required parameters', () {
      const event = ErrorReported(error: 'Test error');

      expect(event.error, 'Test error');
      expect(event.showToUser, true);
      expect(event.severity, ErrorSeverity.high);
    });

    test('ErrorReported creates with all parameters', () {
      final stackTrace = StackTrace.current;
      final event = ErrorReported(
        error: 'Test error',
        stackTrace: stackTrace,
        context: 'Test context',
        showToUser: false,
        severity: ErrorSeverity.low,
      );

      expect(event.stackTrace, stackTrace);
      expect(event.context, 'Test context');
      expect(event.showToUser, false);
      expect(event.severity, ErrorSeverity.low);
    });

    test('ErrorDismissed contains errorId', () {
      const event = ErrorDismissed('error-123');
      expect(event.errorId, 'error-123');
    });

    test('ErrorsCleared has no parameters', () {
      const event = ErrorsCleared();
      expect(event, isNotNull);
    });

    test('ErrorRecovered contains errorId', () {
      const event = ErrorRecovered('error-456');
      expect(event.errorId, 'error-456');
    });

    test('ErrorReported equality', () {
      const event1 = ErrorReported(error: 'Error', severity: ErrorSeverity.high);
      const event2 = ErrorReported(error: 'Error', severity: ErrorSeverity.high);
      expect(event1, equals(event2));
    });

    test('ErrorDismissed equality', () {
      const event1 = ErrorDismissed('id');
      const event2 = ErrorDismissed('id');
      expect(event1, equals(event2));
    });

    test('ErrorRecovered equality', () {
      const event1 = ErrorRecovered('id');
      const event2 = ErrorRecovered('id');
      expect(event1, equals(event2));
    });
  });

  group('ErrorBloc', () {
    late ErrorBloc bloc;

    setUp(() {
      bloc = ErrorBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is empty ErrorState', () {
      expect(bloc.state, const ErrorState());
      expect(bloc.state.activeErrors, isEmpty);
      expect(bloc.state.hasErrors, false);
    });

    blocTest<ErrorBloc, ErrorState>(
      'emits state with error when ErrorReported is added',
      build: () => ErrorBloc(),
      act: (bloc) => bloc.add(const ErrorReported(error: 'Test error')),
      expect: () => [
        isA<ErrorState>()
            .having((s) => s.activeErrors.length, 'activeErrors.length', 1)
            .having((s) => s.activeErrors.first.error, 'error', 'Test error')
            .having(
              (s) => s.activeErrors.first.severity,
              'severity',
              ErrorSeverity.high,
            )
            .having((s) => s.hasErrors, 'hasErrors', true)
            .having((s) => s.lastErrorMessage, 'lastErrorMessage', isNotNull),
      ],
    );

    blocTest<ErrorBloc, ErrorState>(
      'error id is unique for each error',
      build: () => ErrorBloc(),
      act: (bloc) async {
        bloc.add(const ErrorReported(error: 'Error 1'));
        await Future.delayed(const Duration(milliseconds: 10));
        bloc.add(const ErrorReported(error: 'Error 2'));
      },
      verify: (bloc) {
        expect(bloc.state.activeErrors.length, 2);
        expect(
          bloc.state.activeErrors[0].id,
          isNot(bloc.state.activeErrors[1].id),
        );
      },
    );

    blocTest<ErrorBloc, ErrorState>(
      'generates user message for critical severity',
      build: () => ErrorBloc(),
      act: (bloc) => bloc.add(
        ErrorReported(
          error: Exception('Test'),
          severity: ErrorSeverity.critical,
        ),
      ),
      verify: (bloc) {
        expect(
          bloc.state.activeErrors.first.userMessage,
          'A critical error occurred. Please restart the app.',
        );
      },
    );

    blocTest<ErrorBloc, ErrorState>(
      'generates user message for high severity',
      build: () => ErrorBloc(),
      act: (bloc) => bloc.add(
        ErrorReported(
          error: Exception('Test'),
          severity: ErrorSeverity.high,
        ),
      ),
      verify: (bloc) {
        expect(
          bloc.state.activeErrors.first.userMessage,
          'Something went wrong. Please try again.',
        );
      },
    );

    blocTest<ErrorBloc, ErrorState>(
      'generates user message for medium severity',
      build: () => ErrorBloc(),
      act: (bloc) => bloc.add(
        ErrorReported(
          error: Exception('Test'),
          severity: ErrorSeverity.medium,
        ),
      ),
      verify: (bloc) {
        expect(
          bloc.state.activeErrors.first.userMessage,
          'We encountered a small issue. It should resolve shortly.',
        );
      },
    );

    blocTest<ErrorBloc, ErrorState>(
      'generates null user message for low severity',
      build: () => ErrorBloc(),
      act: (bloc) => bloc.add(
        ErrorReported(
          error: Exception('Test'),
          severity: ErrorSeverity.low,
        ),
      ),
      verify: (bloc) {
        expect(bloc.state.activeErrors.first.userMessage, isNull);
      },
    );

    blocTest<ErrorBloc, ErrorState>(
      'uses string error as user message',
      build: () => ErrorBloc(),
      act: (bloc) => bloc.add(
        const ErrorReported(
          error: 'User-visible message',
          severity: ErrorSeverity.high,
        ),
      ),
      verify: (bloc) {
        expect(
          bloc.state.activeErrors.first.userMessage,
          'User-visible message',
        );
      },
    );

    blocTest<ErrorBloc, ErrorState>(
      'removes error when ErrorDismissed is added',
      build: () => ErrorBloc(),
      seed: () {
        final error = AppError(
          id: 'error-to-dismiss',
          error: 'Test',
          severity: ErrorSeverity.high,
        );
        return ErrorState(activeErrors: [error]);
      },
      act: (bloc) => bloc.add(const ErrorDismissed('error-to-dismiss')),
      expect: () => [
        isA<ErrorState>()
            .having((s) => s.activeErrors.isEmpty, 'activeErrors.isEmpty', true),
      ],
    );

    blocTest<ErrorBloc, ErrorState>(
      'does not remove other errors when ErrorDismissed is added',
      build: () => ErrorBloc(),
      seed: () {
        final error1 = AppError(
          id: 'error-1',
          error: 'Test 1',
          severity: ErrorSeverity.high,
        );
        final error2 = AppError(
          id: 'error-2',
          error: 'Test 2',
          severity: ErrorSeverity.high,
        );
        return ErrorState(activeErrors: [error1, error2]);
      },
      act: (bloc) => bloc.add(const ErrorDismissed('error-1')),
      expect: () => [
        isA<ErrorState>()
            .having((s) => s.activeErrors.length, 'activeErrors.length', 1)
            .having((s) => s.activeErrors.first.id, 'remaining id', 'error-2'),
      ],
    );

    blocTest<ErrorBloc, ErrorState>(
      'clears all errors when ErrorsCleared is added',
      build: () => ErrorBloc(),
      seed: () {
        final error1 = AppError(
          id: 'error-1',
          error: 'Test 1',
          severity: ErrorSeverity.high,
        );
        final error2 = AppError(
          id: 'error-2',
          error: 'Test 2',
          severity: ErrorSeverity.low,
        );
        return ErrorState(activeErrors: [error1, error2]);
      },
      act: (bloc) => bloc.add(const ErrorsCleared()),
      expect: () => [
        isA<ErrorState>()
            .having((s) => s.activeErrors.isEmpty, 'activeErrors.isEmpty', true),
      ],
    );

    blocTest<ErrorBloc, ErrorState>(
      'moves error to resolved when ErrorRecovered is added',
      build: () => ErrorBloc(),
      seed: () {
        final error = AppError(
          id: 'error-to-recover',
          error: 'Test',
          severity: ErrorSeverity.high,
        );
        return ErrorState(activeErrors: [error]);
      },
      act: (bloc) => bloc.add(const ErrorRecovered('error-to-recover')),
      expect: () => [
        isA<ErrorState>()
            .having((s) => s.activeErrors.isEmpty, 'activeErrors.isEmpty', true)
            .having((s) => s.resolvedErrors.length, 'resolvedErrors.length', 1)
            .having(
              (s) => s.resolvedErrors.first.id,
              'resolvedErrors.first.id',
              'error-to-recover',
            )
            .having(
              (s) => s.resolvedErrors.first.isResolved,
              'resolvedErrors.first.isResolved',
              true,
            ),
      ],
    );

    group('helper methods', () {
      blocTest<ErrorBloc, ErrorState>(
        'reportError adds ErrorReported event',
        build: () => ErrorBloc(),
        act: (bloc) => bloc.reportError(
          'Test error',
          context: 'Test context',
          severity: ErrorSeverity.medium,
        ),
        verify: (bloc) {
          expect(bloc.state.activeErrors.length, 1);
          expect(bloc.state.activeErrors.first.error, 'Test error');
          expect(bloc.state.activeErrors.first.context, 'Test context');
          expect(bloc.state.activeErrors.first.severity, ErrorSeverity.medium);
        },
      );

      blocTest<ErrorBloc, ErrorState>(
        'reportNetworkError adds error with medium severity',
        build: () => ErrorBloc(),
        act: (bloc) => bloc.reportNetworkError('Network failed'),
        verify: (bloc) {
          expect(bloc.state.activeErrors.length, 1);
          expect(bloc.state.activeErrors.first.severity, ErrorSeverity.medium);
          expect(
            bloc.state.activeErrors.first.context,
            'Network request failed',
          );
        },
      );

      blocTest<ErrorBloc, ErrorState>(
        'reportValidationError adds error with low severity',
        build: () => ErrorBloc(),
        act: (bloc) => bloc.reportValidationError('Invalid input'),
        verify: (bloc) {
          expect(bloc.state.activeErrors.length, 1);
          expect(bloc.state.activeErrors.first.severity, ErrorSeverity.low);
          expect(bloc.state.activeErrors.first.context, 'Validation error');
        },
      );

      blocTest<ErrorBloc, ErrorState>(
        'reportUnexpectedError adds error with high severity',
        build: () => ErrorBloc(),
        act: (bloc) => bloc.reportUnexpectedError(Exception('Unexpected')),
        verify: (bloc) {
          expect(bloc.state.activeErrors.length, 1);
          expect(bloc.state.activeErrors.first.severity, ErrorSeverity.high);
          expect(bloc.state.activeErrors.first.context, 'Unexpected error');
        },
      );
    });
  });
}
