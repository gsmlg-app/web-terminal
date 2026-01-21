import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_terminal/screens/terminal/terminal_screen.dart';

void main() {
  group('TerminalScreen', () {
    test('has correct static name', () {
      expect(TerminalScreen.name, 'TerminalScreen');
    });

    test('has correct static path', () {
      expect(TerminalScreen.path, '/terminal');
    });

    test('can be const constructed', () {
      const screen = TerminalScreen();
      expect(screen, isA<TerminalScreen>());
    });

    test('can be const constructed with key', () {
      const screen = TerminalScreen(key: Key('terminal'));
      expect(screen.key, const Key('terminal'));
    });

    test('is a StatefulWidget', () {
      const screen = TerminalScreen();
      expect(screen, isA<StatefulWidget>());
    });

    test('static name is used for routing', () {
      expect(TerminalScreen.name, isNotEmpty);
      expect(TerminalScreen.name, isNot(contains(' ')));
    });

    test('static path starts with slash', () {
      expect(TerminalScreen.path.startsWith('/'), isTrue);
    });

    test('static path contains "terminal"', () {
      expect(TerminalScreen.path, contains('terminal'));
    });

    test('static path is lowercase', () {
      expect(TerminalScreen.path, TerminalScreen.path.toLowerCase());
    });

    test('static name follows PascalCase convention', () {
      // Name should start with uppercase
      expect(TerminalScreen.name[0], TerminalScreen.name[0].toUpperCase());
    });

    test('creates state when createState is called', () {
      const screen = TerminalScreen();
      final state = screen.createState();
      expect(state, isNotNull);
      expect(state, isA<State<TerminalScreen>>());
    });
  });
}
