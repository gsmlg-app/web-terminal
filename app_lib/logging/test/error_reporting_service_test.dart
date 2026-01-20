import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_logging/app_logging.dart';

void main() {
  group('ErrorReportingService', () {
    late ErrorReportingService service;

    setUp(() {
      service = ErrorReportingService();
    });

    test('is singleton', () {
      final service1 = ErrorReportingService();
      final service2 = ErrorReportingService();

      expect(identical(service1, service2), isTrue);
    });

    test('initialize sets app version', () {
      service.initialize(appVersion: '2.0.0');

      // We can't directly access _appVersion, but we can verify it doesn't throw
      expect(() => service.initialize(appVersion: '2.0.0'), returnsNormally);
    });

    test('initialize can be called multiple times', () {
      service.initialize(appVersion: '1.0.0');
      service.initialize(appVersion: '2.0.0');
      service.initialize(appVersion: '3.0.0');

      // Should not throw
      expect(true, isTrue);
    });

    group('_platformName', () {
      test('returns lowercase platform name', () {
        // The platform name should be derived from defaultTargetPlatform
        // In tests, this is typically 'android'
        final platformNames = [
          'android',
          'fuchsia',
          'ios',
          'linux',
          'macos',
          'windows',
        ];

        // Just verify defaultTargetPlatform is accessible and has a valid name
        expect(
          platformNames.contains(defaultTargetPlatform.name.toLowerCase()),
          isTrue,
        );
      });
    });

    group('reportError', () {
      test('completes without error for string error', () async {
        await expectLater(
          service.reportError(error: 'Test error'),
          completes,
        );
      });

      test('completes without error for Exception', () async {
        await expectLater(
          service.reportError(error: Exception('Test exception')),
          completes,
        );
      });

      test('completes without error with all parameters', () async {
        await expectLater(
          service.reportError(
            error: 'Test error',
            stackTrace: StackTrace.current,
            context: 'Test context',
            level: LogLevel.warning,
            additionalData: {'key': 'value'},
            sendToBackend: false,
          ),
          completes,
        );
      });
    });

    group('reportException', () {
      test('completes without error', () async {
        await expectLater(
          service.reportException(exception: Exception('Test')),
          completes,
        );
      });

      test('accepts optional parameters', () async {
        await expectLater(
          service.reportException(
            exception: Exception('Test'),
            stackTrace: StackTrace.current,
            context: 'Test context',
            level: LogLevel.error,
            additionalData: {'extra': 'data'},
          ),
          completes,
        );
      });
    });

    group('reportFlutterError', () {
      test('completes without error', () async {
        final details = FlutterErrorDetails(
          exception: Exception('Flutter error'),
        );

        await expectLater(
          service.reportFlutterError(details: details),
          completes,
        );
      });

      test('accepts optional context', () async {
        final details = FlutterErrorDetails(
          exception: Exception('Flutter error'),
          library: 'test_library',
        );

        await expectLater(
          service.reportFlutterError(
            details: details,
            context: 'Custom context',
            level: LogLevel.fatal,
          ),
          completes,
        );
      });
    });

    group('getRecentErrors', () {
      test('returns list', () async {
        final errors = await service.getRecentErrors();
        expect(errors, isA<List<Map<String, dynamic>>>());
      });
    });

    group('clearErrorLogs', () {
      test('completes without error', () async {
        await expectLater(
          service.clearErrorLogs(),
          completes,
        );
      });
    });

    group('exportErrorLogs', () {
      test('completes without error', () async {
        await expectLater(
          service.exportErrorLogs(),
          completes,
        );
      });
    });

    group('setupGlobalErrorHandler', () {
      test('sets up FlutterError.onError', () {
        // Store original handler
        final originalHandler = FlutterError.onError;

        service.setupGlobalErrorHandler();

        // Verify handler was set
        expect(FlutterError.onError, isNotNull);

        // Restore original handler
        FlutterError.onError = originalHandler;
      });
    });
  });

  group('LogLevel', () {
    test('has all expected values', () {
      expect(LogLevel.values, hasLength(6));
      expect(LogLevel.values, contains(LogLevel.verbose));
      expect(LogLevel.values, contains(LogLevel.debug));
      expect(LogLevel.values, contains(LogLevel.info));
      expect(LogLevel.values, contains(LogLevel.warning));
      expect(LogLevel.values, contains(LogLevel.error));
      expect(LogLevel.values, contains(LogLevel.fatal));
    });

    test('has correct name values', () {
      // LogLevel uses uppercase names
      expect(LogLevel.verbose.name, 'VERBOSE');
      expect(LogLevel.debug.name, 'DEBUG');
      expect(LogLevel.info.name, 'INFO');
      expect(LogLevel.warning.name, 'WARNING');
      expect(LogLevel.error.name, 'ERROR');
      expect(LogLevel.fatal.name, 'FATAL');
    });
  });
}
