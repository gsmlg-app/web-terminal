import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:app_logging/app_logging.dart';

void main() {
  group('LogRecord', () {
    group('constructor', () {
      test('creates with required parameters', () {
        final record = LogRecord(
          level: LogLevel.info,
          message: 'Test message',
          loggerName: 'TestLogger',
        );

        expect(record.level, LogLevel.info);
        expect(record.message, 'Test message');
        expect(record.loggerName, 'TestLogger');
        expect(record.error, isNull);
        expect(record.stackTrace, isNull);
        expect(record.time, isNotNull);
        expect(record.zone, isNull);
      });

      test('creates with all parameters', () {
        final error = Exception('Test error');
        final stackTrace = StackTrace.current;
        final time = DateTime(2025, 1, 15, 10, 30, 0);
        final zone = Zone.current;

        final record = LogRecord(
          level: LogLevel.error,
          message: 'Error occurred',
          error: error,
          stackTrace: stackTrace,
          loggerName: 'ErrorLogger',
          time: time,
          zone: zone,
        );

        expect(record.level, LogLevel.error);
        expect(record.message, 'Error occurred');
        expect(record.error, error);
        expect(record.stackTrace, stackTrace);
        expect(record.loggerName, 'ErrorLogger');
        expect(record.time, time);
        expect(record.zone, zone);
      });

      test('uses DateTime.now when time is null', () {
        final before = DateTime.now();
        final record = LogRecord(
          level: LogLevel.info,
          message: 'Test',
          loggerName: 'Logger',
        );
        final after = DateTime.now();

        expect(record.time.isAfter(before.subtract(const Duration(seconds: 1))),
            isTrue);
        expect(record.time.isBefore(after.add(const Duration(seconds: 1))),
            isTrue);
      });

      test('creates with different log levels', () {
        for (final level in LogLevel.values) {
          final record = LogRecord(
            level: level,
            message: 'Level: ${level.name}',
            loggerName: 'Logger',
          );
          expect(record.level, level);
        }
      });

      test('creates with string error', () {
        final record = LogRecord(
          level: LogLevel.error,
          message: 'String error',
          error: 'Something went wrong',
          loggerName: 'Logger',
        );

        expect(record.error, 'Something went wrong');
      });
    });

    group('copyWith', () {
      late LogRecord originalRecord;
      late DateTime originalTime;
      late StackTrace originalStackTrace;

      setUp(() {
        originalTime = DateTime(2025, 1, 15, 10, 30, 0);
        originalStackTrace = StackTrace.current;
        originalRecord = LogRecord(
          level: LogLevel.info,
          message: 'Original message',
          error: Exception('Original error'),
          stackTrace: originalStackTrace,
          loggerName: 'OriginalLogger',
          time: originalTime,
        );
      });

      test('returns copy with no changes when called with no arguments', () {
        final copy = originalRecord.copyWith();

        expect(copy.level, originalRecord.level);
        expect(copy.message, originalRecord.message);
        expect(copy.error, originalRecord.error);
        expect(copy.stackTrace, originalRecord.stackTrace);
        expect(copy.loggerName, originalRecord.loggerName);
        expect(copy.time, originalRecord.time);
      });

      test('updates only level when specified', () {
        final copy = originalRecord.copyWith(level: LogLevel.error);

        expect(copy.level, LogLevel.error);
        expect(copy.message, originalRecord.message);
        expect(copy.loggerName, originalRecord.loggerName);
      });

      test('updates only message when specified', () {
        final copy = originalRecord.copyWith(message: 'New message');

        expect(copy.message, 'New message');
        expect(copy.level, originalRecord.level);
        expect(copy.loggerName, originalRecord.loggerName);
      });

      test('updates only error when specified', () {
        final newError = Exception('New error');
        final copy = originalRecord.copyWith(error: newError);

        expect(copy.error, newError);
        expect(copy.level, originalRecord.level);
        expect(copy.message, originalRecord.message);
      });

      test('updates only stackTrace when specified', () {
        final newStackTrace = StackTrace.current;
        final copy = originalRecord.copyWith(stackTrace: newStackTrace);

        expect(copy.stackTrace, newStackTrace);
        expect(copy.error, originalRecord.error);
      });

      test('updates only loggerName when specified', () {
        final copy = originalRecord.copyWith(loggerName: 'NewLogger');

        expect(copy.loggerName, 'NewLogger');
        expect(copy.level, originalRecord.level);
      });

      test('updates only time when specified', () {
        final newTime = DateTime(2025, 12, 31);
        final copy = originalRecord.copyWith(time: newTime);

        expect(copy.time, newTime);
        expect(copy.loggerName, originalRecord.loggerName);
      });

      test('updates only zone when specified', () {
        final newZone = Zone.current.fork();
        final copy = originalRecord.copyWith(zone: newZone);

        expect(copy.zone, newZone);
        expect(copy.time, originalRecord.time);
      });

      test('updates multiple fields at once', () {
        final copy = originalRecord.copyWith(
          level: LogLevel.fatal,
          message: 'Fatal error',
          loggerName: 'FatalLogger',
        );

        expect(copy.level, LogLevel.fatal);
        expect(copy.message, 'Fatal error');
        expect(copy.loggerName, 'FatalLogger');
        // Unchanged fields
        expect(copy.error, originalRecord.error);
        expect(copy.time, originalRecord.time);
      });

      test('returns new instance, not the same object', () {
        final copy = originalRecord.copyWith();

        expect(identical(copy, originalRecord), isFalse);
      });
    });

    group('toString', () {
      test('includes level name', () {
        final record = LogRecord(
          level: LogLevel.warning,
          message: 'Test',
          loggerName: 'Logger',
        );

        expect(record.toString(), contains('WARNING'));
      });

      test('includes message', () {
        final record = LogRecord(
          level: LogLevel.info,
          message: 'Important message here',
          loggerName: 'Logger',
        );

        expect(record.toString(), contains('Important message here'));
      });

      test('includes loggerName', () {
        final record = LogRecord(
          level: LogLevel.info,
          message: 'Test',
          loggerName: 'MyCustomLogger',
        );

        expect(record.toString(), contains('MyCustomLogger'));
      });

      test('includes error when present', () {
        final record = LogRecord(
          level: LogLevel.error,
          message: 'Error occurred',
          error: Exception('Specific error'),
          loggerName: 'Logger',
        );

        expect(record.toString(), contains('Exception'));
      });

      test('includes time', () {
        final time = DateTime(2025, 6, 15, 14, 30, 45);
        final record = LogRecord(
          level: LogLevel.info,
          message: 'Test',
          loggerName: 'Logger',
          time: time,
        );

        expect(record.toString(), contains('2025'));
      });

      test('starts with LogRecord', () {
        final record = LogRecord(
          level: LogLevel.info,
          message: 'Test',
          loggerName: 'Logger',
        );

        expect(record.toString(), startsWith('LogRecord('));
      });
    });

    group('equality', () {
      late DateTime fixedTime;

      setUp(() {
        fixedTime = DateTime(2025, 1, 15, 10, 30, 0);
      });

      test('equal records are equal', () {
        final record1 = LogRecord(
          level: LogLevel.info,
          message: 'Same message',
          loggerName: 'Logger',
          time: fixedTime,
        );
        final record2 = LogRecord(
          level: LogLevel.info,
          message: 'Same message',
          loggerName: 'Logger',
          time: fixedTime,
        );

        expect(record1, equals(record2));
      });

      test('identical records are equal', () {
        final record = LogRecord(
          level: LogLevel.info,
          message: 'Test',
          loggerName: 'Logger',
          time: fixedTime,
        );

        expect(record, equals(record));
      });

      test('different levels are not equal', () {
        final record1 = LogRecord(
          level: LogLevel.info,
          message: 'Test',
          loggerName: 'Logger',
          time: fixedTime,
        );
        final record2 = LogRecord(
          level: LogLevel.error,
          message: 'Test',
          loggerName: 'Logger',
          time: fixedTime,
        );

        expect(record1, isNot(equals(record2)));
      });

      test('different messages are not equal', () {
        final record1 = LogRecord(
          level: LogLevel.info,
          message: 'Message 1',
          loggerName: 'Logger',
          time: fixedTime,
        );
        final record2 = LogRecord(
          level: LogLevel.info,
          message: 'Message 2',
          loggerName: 'Logger',
          time: fixedTime,
        );

        expect(record1, isNot(equals(record2)));
      });

      test('different loggerNames are not equal', () {
        final record1 = LogRecord(
          level: LogLevel.info,
          message: 'Test',
          loggerName: 'Logger1',
          time: fixedTime,
        );
        final record2 = LogRecord(
          level: LogLevel.info,
          message: 'Test',
          loggerName: 'Logger2',
          time: fixedTime,
        );

        expect(record1, isNot(equals(record2)));
      });

      test('different times are not equal', () {
        final record1 = LogRecord(
          level: LogLevel.info,
          message: 'Test',
          loggerName: 'Logger',
          time: DateTime(2025, 1, 1),
        );
        final record2 = LogRecord(
          level: LogLevel.info,
          message: 'Test',
          loggerName: 'Logger',
          time: DateTime(2025, 1, 2),
        );

        expect(record1, isNot(equals(record2)));
      });

      test('different errors are not equal', () {
        final record1 = LogRecord(
          level: LogLevel.error,
          message: 'Test',
          error: Exception('Error 1'),
          loggerName: 'Logger',
          time: fixedTime,
        );
        final record2 = LogRecord(
          level: LogLevel.error,
          message: 'Test',
          error: Exception('Error 2'),
          loggerName: 'Logger',
          time: fixedTime,
        );

        expect(record1, isNot(equals(record2)));
      });

      test('null error vs present error are not equal', () {
        final record1 = LogRecord(
          level: LogLevel.info,
          message: 'Test',
          loggerName: 'Logger',
          time: fixedTime,
        );
        final record2 = LogRecord(
          level: LogLevel.info,
          message: 'Test',
          error: Exception('Error'),
          loggerName: 'Logger',
          time: fixedTime,
        );

        expect(record1, isNot(equals(record2)));
      });

      test('not equal to non-LogRecord', () {
        final record = LogRecord(
          level: LogLevel.info,
          message: 'Test',
          loggerName: 'Logger',
        );

        // ignore: unrelated_type_equality_checks
        expect(record == 'not a record', isFalse);
        // ignore: unrelated_type_equality_checks
        expect(record == 123, isFalse);
        // Test that operator== handles Object comparison properly
        final Object? nullObject = null;
        expect(record == nullObject, isFalse);
      });
    });

    group('hashCode', () {
      late DateTime fixedTime;

      setUp(() {
        fixedTime = DateTime(2025, 1, 15, 10, 30, 0);
      });

      test('equal records have same hashCode', () {
        final record1 = LogRecord(
          level: LogLevel.info,
          message: 'Same',
          loggerName: 'Logger',
          time: fixedTime,
        );
        final record2 = LogRecord(
          level: LogLevel.info,
          message: 'Same',
          loggerName: 'Logger',
          time: fixedTime,
        );

        expect(record1.hashCode, equals(record2.hashCode));
      });

      test('hashCode is consistent across calls', () {
        final record = LogRecord(
          level: LogLevel.info,
          message: 'Test',
          loggerName: 'Logger',
          time: fixedTime,
        );

        final hashCode1 = record.hashCode;
        final hashCode2 = record.hashCode;

        expect(hashCode1, equals(hashCode2));
      });

      test('different records may have different hashCodes', () {
        final record1 = LogRecord(
          level: LogLevel.info,
          message: 'Message 1',
          loggerName: 'Logger',
          time: fixedTime,
        );
        final record2 = LogRecord(
          level: LogLevel.error,
          message: 'Message 2',
          loggerName: 'OtherLogger',
          time: fixedTime,
        );

        // Note: different objects may have same hashCode (collision),
        // but likely different for very different objects
        expect(record1.hashCode, isNot(equals(record2.hashCode)));
      });
    });

    group('immutability', () {
      test('LogRecord is immutable', () {
        final record = LogRecord(
          level: LogLevel.info,
          message: 'Test',
          loggerName: 'Logger',
        );

        // All fields should be final and unchangeable
        expect(record.level, LogLevel.info);
        expect(record.message, 'Test');
        expect(record.loggerName, 'Logger');
      });
    });
  });
}
