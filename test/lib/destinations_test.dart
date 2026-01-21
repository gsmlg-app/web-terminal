import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_terminal/destinations.dart';

void main() {
  group('Destinations static constants', () {
    test('terminalScreenName is defined', () {
      expect(Destinations.terminalScreenName, isNotNull);
      expect(Destinations.terminalScreenName, 'TerminalScreen');
    });

    test('webTerminalScreenName is defined', () {
      expect(Destinations.webTerminalScreenName, isNotNull);
      expect(Destinations.webTerminalScreenName, 'WebTerminalScreen');
    });

    test('settingsScreenName is defined', () {
      expect(Destinations.settingsScreenName, isNotNull);
      expect(Destinations.settingsScreenName, 'Settings');
    });

    test('screen names are unique', () {
      final names = [
        Destinations.terminalScreenName,
        Destinations.webTerminalScreenName,
        Destinations.settingsScreenName,
      ];
      expect(names.toSet().length, names.length,
          reason: 'All screen names should be unique');
    });
  });

  group('Destinations.navs', () {
    test('navs returns method reference', () {
      expect(Destinations.navs, isNotNull);
    });
  });

  group('Destinations.indexOf', () {
    test('indexOf returns method reference', () {
      expect(Destinations.indexOf, isNotNull);
    });
  });

  group('Destinations.changeHandler', () {
    test('changeHandler returns method reference', () {
      expect(Destinations.changeHandler, isNotNull);
    });
  });
}
