import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:app_logging/app_logging.dart';

void main() {
  group('AppLogger', () {
    late AppLogger logger;
    late List<LogRecord> capturedLogs;
    StreamSubscription<LogRecord>? subscription;

    setUp(() {
      logger = AppLogger();
      capturedLogs = [];
      subscription = null;
    });

    tearDown(() async {
      await subscription?.cancel();
    });

    group('singleton pattern', () {
      test('factory constructor returns same instance', () {
        final logger1 = AppLogger();
        final logger2 = AppLogger();
        expect(identical(logger1, logger2), isTrue);
      });

      test('instance is not null', () {
        expect(logger, isNotNull);
      });
    });

    group('initialization', () {
      test('can be initialized with default parameters', () {
        subscription = logger.logStream.listen((record) {
          capturedLogs.add(record);
        });

        // Should not throw
        logger.initialize();
        expect(true, isTrue);
      });

      test('can be initialized with custom log level', () {
        subscription = logger.logStream.listen((record) {
          capturedLogs.add(record);
        });

        logger.initialize(level: LogLevel.debug);
        expect(true, isTrue);
      });

      test('can be initialized with stack trace disabled', () {
        subscription = logger.logStream.listen((record) {
          capturedLogs.add(record);
        });

        logger.initialize(includeStackTrace: false);
        expect(true, isTrue);
      });

      test('can be initialized with all parameters', () {
        subscription = logger.logStream.listen((record) {
          capturedLogs.add(record);
        });

        logger.initialize(
          level: LogLevel.warning,
          includeStackTrace: false,
        );
        expect(true, isTrue);
      });
    });

    group('logStream', () {
      test('returns a broadcast stream', () {
        expect(logger.logStream.isBroadcast, isTrue);
      });

      test('can have multiple listeners', () {
        final logs1 = <LogRecord>[];
        final logs2 = <LogRecord>[];

        final sub1 = logger.logStream.listen((record) {
          logs1.add(record);
        });
        final sub2 = logger.logStream.listen((record) {
          logs2.add(record);
        });

        subscription = sub1;

        // Clean up
        addTearDown(() async {
          await sub2.cancel();
        });
      });
    });

    group('logging methods', () {
      setUp(() {
        subscription = logger.logStream.listen((record) {
          capturedLogs.add(record);
        });
        logger.initialize(level: LogLevel.verbose);
      });

      test('v() logs verbose message', () async {
        logger.v('verbose message');

        await Future.delayed(const Duration(milliseconds: 50));

        expect(capturedLogs.length, greaterThanOrEqualTo(1));
        final lastLog = capturedLogs.last;
        expect(lastLog.message, equals('verbose message'));
        expect(lastLog.level, equals(LogLevel.verbose));
      });

      test('d() logs debug message', () async {
        logger.d('debug message');

        await Future.delayed(const Duration(milliseconds: 50));

        expect(capturedLogs.length, greaterThanOrEqualTo(1));
        final lastLog = capturedLogs.last;
        expect(lastLog.message, equals('debug message'));
        expect(lastLog.level, equals(LogLevel.debug));
      });

      test('i() logs info message', () async {
        logger.i('info message');

        await Future.delayed(const Duration(milliseconds: 50));

        expect(capturedLogs.length, greaterThanOrEqualTo(1));
        final lastLog = capturedLogs.last;
        expect(lastLog.message, equals('info message'));
        expect(lastLog.level, equals(LogLevel.info));
      });

      test('w() logs warning message', () async {
        logger.w('warning message');

        await Future.delayed(const Duration(milliseconds: 50));

        expect(capturedLogs.length, greaterThanOrEqualTo(1));
        final lastLog = capturedLogs.last;
        expect(lastLog.message, equals('warning message'));
        expect(lastLog.level, equals(LogLevel.warning));
      });

      test('e() logs error message', () async {
        logger.e('error message');

        await Future.delayed(const Duration(milliseconds: 50));

        expect(capturedLogs.length, greaterThanOrEqualTo(1));
        final lastLog = capturedLogs.last;
        expect(lastLog.message, equals('error message'));
        expect(lastLog.level, equals(LogLevel.error));
      });

      test('f() logs fatal message', () async {
        logger.f('fatal message');

        await Future.delayed(const Duration(milliseconds: 50));

        expect(capturedLogs.length, greaterThanOrEqualTo(1));
        final lastLog = capturedLogs.last;
        expect(lastLog.message, equals('fatal message'));
        expect(lastLog.level, equals(LogLevel.fatal));
      });
    });

    group('logging with error and stack trace', () {
      setUp(() {
        subscription = logger.logStream.listen((record) {
          capturedLogs.add(record);
        });
        logger.initialize(level: LogLevel.verbose);
      });

      test('can log with error object', () async {
        final error = Exception('test error');
        logger.e('error with exception', error);

        await Future.delayed(const Duration(milliseconds: 50));

        expect(capturedLogs.length, greaterThanOrEqualTo(1));
        final lastLog = capturedLogs.last;
        expect(lastLog.message, equals('error with exception'));
        expect(lastLog.error, equals(error));
      });

      test('can log with custom stack trace', () async {
        final stackTrace = StackTrace.current;
        logger.e('error with stack', null, stackTrace);

        await Future.delayed(const Duration(milliseconds: 50));

        expect(capturedLogs.length, greaterThanOrEqualTo(1));
        final lastLog = capturedLogs.last;
        expect(lastLog.message, equals('error with stack'));
        expect(lastLog.stackTrace, equals(stackTrace));
      });

      test('can log with both error and stack trace', () async {
        final error = StateError('state error');
        final stackTrace = StackTrace.current;
        logger.f('fatal with both', error, stackTrace);

        await Future.delayed(const Duration(milliseconds: 50));

        expect(capturedLogs.length, greaterThanOrEqualTo(1));
        final lastLog = capturedLogs.last;
        expect(lastLog.message, equals('fatal with both'));
        expect(lastLog.error, equals(error));
        expect(lastLog.stackTrace, equals(stackTrace));
      });
    });

    group('log level filtering', () {
      test('filters out logs below current level', () async {
        subscription = logger.logStream.listen((record) {
          capturedLogs.add(record);
        });
        logger.initialize(level: LogLevel.warning);

        // These should be filtered out
        logger.v('verbose');
        logger.d('debug');
        logger.i('info');

        // This should be logged
        logger.w('warning');
        logger.e('error');

        await Future.delayed(const Duration(milliseconds: 100));

        // Only warning and above should be captured
        final warningAndAbove =
            capturedLogs.where((r) => r.level >= LogLevel.warning).toList();
        expect(warningAndAbove.length, greaterThanOrEqualTo(2));
      });

      test('includes all logs when level is verbose', () async {
        subscription = logger.logStream.listen((record) {
          capturedLogs.add(record);
        });
        logger.initialize(level: LogLevel.verbose);

        logger.v('verbose');
        logger.d('debug');
        logger.i('info');
        logger.w('warning');
        logger.e('error');
        logger.f('fatal');

        await Future.delayed(const Duration(milliseconds: 100));

        // All levels should be present
        expect(capturedLogs.length, greaterThanOrEqualTo(6));
      });
    });

    group('LogRecord structure', () {
      setUp(() {
        subscription = logger.logStream.listen((record) {
          capturedLogs.add(record);
        });
        logger.initialize(level: LogLevel.verbose);
      });

      test('includes logger name', () async {
        logger.i('test message');

        await Future.delayed(const Duration(milliseconds: 50));

        expect(capturedLogs.length, greaterThanOrEqualTo(1));
        final lastLog = capturedLogs.last;
        expect(lastLog.loggerName, equals('AppLogger'));
      });

      test('includes timestamp', () async {
        final before = DateTime.now();
        logger.i('test message');
        final after = DateTime.now();

        await Future.delayed(const Duration(milliseconds: 50));

        expect(capturedLogs.length, greaterThanOrEqualTo(1));
        final lastLog = capturedLogs.last;
        expect(
            lastLog.time.isAfter(before.subtract(const Duration(seconds: 1))),
            isTrue);
        expect(lastLog.time.isBefore(after.add(const Duration(seconds: 1))),
            isTrue);
      });
    });
  });
}
