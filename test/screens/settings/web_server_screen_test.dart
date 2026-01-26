import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_terminal/screens/settings/web_server/web_server_screen.dart';

void main() {
  group('WebServerScreen', () {
    test('has correct static name', () {
      expect(WebServerScreen.name, 'web-server');
    });

    test('has correct static path', () {
      expect(WebServerScreen.path, 'web-server');
    });

    test('static name and path are equal', () {
      expect(WebServerScreen.name, equals(WebServerScreen.path));
    });

    test('can be const constructed', () {
      const screen = WebServerScreen();
      expect(screen, isA<WebServerScreen>());
    });

    test('can be const constructed with key', () {
      const screen = WebServerScreen(key: Key('web-server'));
      expect(screen.key, const Key('web-server'));
    });

    test('is a StatefulWidget', () {
      const screen = WebServerScreen();
      expect(screen, isA<StatefulWidget>());
    });

    test('static path is lowercase with hyphens', () {
      expect(WebServerScreen.path, WebServerScreen.path.toLowerCase());
      expect(WebServerScreen.path, contains('-'));
    });

    test('static path does not start with slash (relative path)', () {
      expect(WebServerScreen.path.startsWith('/'), isFalse);
    });

    test('creates state when createState is called', () {
      const screen = WebServerScreen();
      final state = screen.createState();
      expect(state, isNotNull);
      expect(state, isA<State<WebServerScreen>>());
    });

    test('static name does not use underscores', () {
      expect(WebServerScreen.name.contains('_'), isFalse);
    });
  });
}
