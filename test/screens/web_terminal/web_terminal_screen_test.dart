import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_terminal/screens/web_terminal/web_terminal_screen.dart';

void main() {
  group('WebTerminalScreen', () {
    test('has correct static name', () {
      expect(WebTerminalScreen.name, 'WebTerminalScreen');
    });

    test('has correct static path', () {
      expect(WebTerminalScreen.path, '/web-terminal');
    });

    test('can be const constructed', () {
      const screen = WebTerminalScreen();
      expect(screen, isA<WebTerminalScreen>());
    });

    test('can be const constructed with key', () {
      const screen = WebTerminalScreen(key: Key('web-terminal'));
      expect(screen.key, const Key('web-terminal'));
    });

    test('is a StatelessWidget', () {
      const screen = WebTerminalScreen();
      expect(screen, isA<StatelessWidget>());
    });

    test('static name is used for routing', () {
      // The screen name should be suitable for use with GoRouter
      expect(WebTerminalScreen.name, isNotEmpty);
      expect(WebTerminalScreen.name, isNot(contains(' ')));
    });

    test('static path starts with slash', () {
      expect(WebTerminalScreen.path.startsWith('/'), isTrue);
    });

    test('static path contains "web-terminal"', () {
      expect(WebTerminalScreen.path, contains('web-terminal'));
    });
  });
}
