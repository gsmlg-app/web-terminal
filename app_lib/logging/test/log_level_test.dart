import 'package:flutter_test/flutter_test.dart';
import 'package:app_logging/app_logging.dart';

void main() {
  group('LogLevel', () {
    group('enum values', () {
      test('has 6 log levels', () {
        expect(LogLevel.values, hasLength(6));
      });

      test('verbose is level 0', () {
        expect(LogLevel.verbose.value, 0);
        expect(LogLevel.verbose.name, 'VERBOSE');
      });

      test('debug is level 1', () {
        expect(LogLevel.debug.value, 1);
        expect(LogLevel.debug.name, 'DEBUG');
      });

      test('info is level 2', () {
        expect(LogLevel.info.value, 2);
        expect(LogLevel.info.name, 'INFO');
      });

      test('warning is level 3', () {
        expect(LogLevel.warning.value, 3);
        expect(LogLevel.warning.name, 'WARNING');
      });

      test('error is level 4', () {
        expect(LogLevel.error.value, 4);
        expect(LogLevel.error.name, 'ERROR');
      });

      test('fatal is level 5', () {
        expect(LogLevel.fatal.value, 5);
        expect(LogLevel.fatal.name, 'FATAL');
      });

      test('values are ordered by severity', () {
        expect(LogLevel.verbose.value, lessThan(LogLevel.debug.value));
        expect(LogLevel.debug.value, lessThan(LogLevel.info.value));
        expect(LogLevel.info.value, lessThan(LogLevel.warning.value));
        expect(LogLevel.warning.value, lessThan(LogLevel.error.value));
        expect(LogLevel.error.value, lessThan(LogLevel.fatal.value));
      });
    });

    group('operator >=', () {
      test('verbose >= verbose is true', () {
        expect(LogLevel.verbose >= LogLevel.verbose, isTrue);
      });

      test('fatal >= verbose is true', () {
        expect(LogLevel.fatal >= LogLevel.verbose, isTrue);
      });

      test('verbose >= fatal is false', () {
        expect(LogLevel.verbose >= LogLevel.fatal, isFalse);
      });

      test('info >= info is true', () {
        expect(LogLevel.info >= LogLevel.info, isTrue);
      });

      test('warning >= info is true', () {
        expect(LogLevel.warning >= LogLevel.info, isTrue);
      });

      test('info >= warning is false', () {
        expect(LogLevel.info >= LogLevel.warning, isFalse);
      });
    });

    group('operator >', () {
      test('verbose > verbose is false', () {
        expect(LogLevel.verbose > LogLevel.verbose, isFalse);
      });

      test('fatal > verbose is true', () {
        expect(LogLevel.fatal > LogLevel.verbose, isTrue);
      });

      test('verbose > fatal is false', () {
        expect(LogLevel.verbose > LogLevel.fatal, isFalse);
      });

      test('error > warning is true', () {
        expect(LogLevel.error > LogLevel.warning, isTrue);
      });

      test('warning > warning is false', () {
        expect(LogLevel.warning > LogLevel.warning, isFalse);
      });
    });

    group('operator <=', () {
      test('verbose <= verbose is true', () {
        expect(LogLevel.verbose <= LogLevel.verbose, isTrue);
      });

      test('verbose <= fatal is true', () {
        expect(LogLevel.verbose <= LogLevel.fatal, isTrue);
      });

      test('fatal <= verbose is false', () {
        expect(LogLevel.fatal <= LogLevel.verbose, isFalse);
      });

      test('info <= warning is true', () {
        expect(LogLevel.info <= LogLevel.warning, isTrue);
      });

      test('info <= info is true', () {
        expect(LogLevel.info <= LogLevel.info, isTrue);
      });
    });

    group('operator <', () {
      test('verbose < verbose is false', () {
        expect(LogLevel.verbose < LogLevel.verbose, isFalse);
      });

      test('verbose < fatal is true', () {
        expect(LogLevel.verbose < LogLevel.fatal, isTrue);
      });

      test('fatal < verbose is false', () {
        expect(LogLevel.fatal < LogLevel.verbose, isFalse);
      });

      test('debug < info is true', () {
        expect(LogLevel.debug < LogLevel.info, isTrue);
      });

      test('error < error is false', () {
        expect(LogLevel.error < LogLevel.error, isFalse);
      });
    });

    group('comparison chaining', () {
      test('verbose < debug < info < warning < error < fatal', () {
        final levels = LogLevel.values.toList()
          ..sort((a, b) => a.value.compareTo(b.value));

        expect(levels, [
          LogLevel.verbose,
          LogLevel.debug,
          LogLevel.info,
          LogLevel.warning,
          LogLevel.error,
          LogLevel.fatal,
        ]);
      });

      test('all levels >= verbose', () {
        for (final level in LogLevel.values) {
          expect(level >= LogLevel.verbose, isTrue,
              reason: '${level.name} should be >= VERBOSE');
        }
      });

      test('all levels <= fatal', () {
        for (final level in LogLevel.values) {
          expect(level <= LogLevel.fatal, isTrue,
              reason: '${level.name} should be <= FATAL');
        }
      });
    });

    group('use case scenarios', () {
      test('filtering logs by minimum level', () {
        const minimumLevel = LogLevel.warning;
        final passedLevels =
            LogLevel.values.where((level) => level >= minimumLevel).toList();

        expect(
            passedLevels,
            containsAll([
              LogLevel.warning,
              LogLevel.error,
              LogLevel.fatal,
            ]));
        expect(passedLevels, isNot(contains(LogLevel.verbose)));
        expect(passedLevels, isNot(contains(LogLevel.debug)));
        expect(passedLevels, isNot(contains(LogLevel.info)));
      });

      test('filtering logs by maximum level', () {
        const maximumLevel = LogLevel.info;
        final passedLevels =
            LogLevel.values.where((level) => level <= maximumLevel).toList();

        expect(
            passedLevels,
            containsAll([
              LogLevel.verbose,
              LogLevel.debug,
              LogLevel.info,
            ]));
        expect(passedLevels, isNot(contains(LogLevel.warning)));
        expect(passedLevels, isNot(contains(LogLevel.error)));
        expect(passedLevels, isNot(contains(LogLevel.fatal)));
      });

      test('checking if level should be logged', () {
        bool shouldLog(LogLevel currentLevel, LogLevel minimumLevel) {
          return currentLevel >= minimumLevel;
        }

        expect(shouldLog(LogLevel.error, LogLevel.info), isTrue);
        expect(shouldLog(LogLevel.debug, LogLevel.info), isFalse);
        expect(shouldLog(LogLevel.info, LogLevel.info), isTrue);
      });
    });
  });
}
