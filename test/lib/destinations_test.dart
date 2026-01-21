import 'package:flutter_test/flutter_test.dart';
import 'package:web_terminal/destinations.dart';

void main() {
  group('Destinations static constants', () {
    group('terminalScreenName', () {
      test('is defined', () {
        expect(Destinations.terminalScreenName, isNotNull);
      });

      test('equals "TerminalScreen"', () {
        expect(Destinations.terminalScreenName, 'TerminalScreen');
      });

      test('is a String', () {
        expect(Destinations.terminalScreenName, isA<String>());
      });

      test('is not empty', () {
        expect(Destinations.terminalScreenName, isNotEmpty);
      });
    });

    group('webTerminalScreenName', () {
      test('is defined', () {
        expect(Destinations.webTerminalScreenName, isNotNull);
      });

      test('equals "WebTerminalScreen"', () {
        expect(Destinations.webTerminalScreenName, 'WebTerminalScreen');
      });

      test('is a String', () {
        expect(Destinations.webTerminalScreenName, isA<String>());
      });

      test('is not empty', () {
        expect(Destinations.webTerminalScreenName, isNotEmpty);
      });
    });

    group('settingsScreenName', () {
      test('is defined', () {
        expect(Destinations.settingsScreenName, isNotNull);
      });

      test('equals "Settings"', () {
        expect(Destinations.settingsScreenName, 'Settings');
      });

      test('is a String', () {
        expect(Destinations.settingsScreenName, isA<String>());
      });

      test('is not empty', () {
        expect(Destinations.settingsScreenName, isNotEmpty);
      });
    });

    group('uniqueness', () {
      test('all screen names are unique', () {
        final names = [
          Destinations.terminalScreenName,
          Destinations.webTerminalScreenName,
          Destinations.settingsScreenName,
        ];
        expect(names.toSet().length, names.length,
            reason: 'All screen names should be unique');
      });

      test('terminalScreenName differs from webTerminalScreenName', () {
        expect(
          Destinations.terminalScreenName,
          isNot(equals(Destinations.webTerminalScreenName)),
        );
      });

      test('terminalScreenName differs from settingsScreenName', () {
        expect(
          Destinations.terminalScreenName,
          isNot(equals(Destinations.settingsScreenName)),
        );
      });

      test('webTerminalScreenName differs from settingsScreenName', () {
        expect(
          Destinations.webTerminalScreenName,
          isNot(equals(Destinations.settingsScreenName)),
        );
      });
    });

    group('naming conventions', () {
      test('all names use PascalCase', () {
        // Check that names start with uppercase
        expect(
          Destinations.terminalScreenName[0],
          equals(Destinations.terminalScreenName[0].toUpperCase()),
        );
        expect(
          Destinations.webTerminalScreenName[0],
          equals(Destinations.webTerminalScreenName[0].toUpperCase()),
        );
        expect(
          Destinations.settingsScreenName[0],
          equals(Destinations.settingsScreenName[0].toUpperCase()),
        );
      });

      test('names do not contain spaces', () {
        expect(Destinations.terminalScreenName, isNot(contains(' ')));
        expect(Destinations.webTerminalScreenName, isNot(contains(' ')));
        expect(Destinations.settingsScreenName, isNot(contains(' ')));
      });
    });
  });

  group('Destinations.navs', () {
    test('returns method reference', () {
      expect(Destinations.navs, isNotNull);
    });

    test('is a Function', () {
      expect(Destinations.navs, isA<Function>());
    });
  });

  group('Destinations.indexOf', () {
    test('returns method reference', () {
      expect(Destinations.indexOf, isNotNull);
    });

    test('is a Function', () {
      expect(Destinations.indexOf, isA<Function>());
    });
  });

  group('Destinations.changeHandler', () {
    test('returns method reference', () {
      expect(Destinations.changeHandler, isNotNull);
    });

    test('is a Function', () {
      expect(Destinations.changeHandler, isA<Function>());
    });
  });

  group('Destinations class', () {
    test('class exists', () {
      expect(Destinations, isNotNull);
    });

    test('has three screen name constants', () {
      // Verify all three constants are accessible
      expect(Destinations.terminalScreenName, isNotNull);
      expect(Destinations.webTerminalScreenName, isNotNull);
      expect(Destinations.settingsScreenName, isNotNull);
    });

    test('has three method references', () {
      // Verify all three methods are accessible
      expect(Destinations.navs, isNotNull);
      expect(Destinations.indexOf, isNotNull);
      expect(Destinations.changeHandler, isNotNull);
    });
  });
}
