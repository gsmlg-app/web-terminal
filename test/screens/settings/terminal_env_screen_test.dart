import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_terminal/screens/settings/_setting_config.dart';
import 'package:web_terminal/screens/settings/terminal_env_screen.dart';

void main() {
  group('TerminalEnvScreen', () {
    test('has correct static name from SettingsScreenNames', () {
      expect(TerminalEnvScreen.name, SettingsScreenNames.terminalEnv);
      expect(TerminalEnvScreen.name, 'Terminal Environment');
    });

    test('has correct static path', () {
      expect(TerminalEnvScreen.path, 'terminal-env');
    });

    test('can be const constructed', () {
      const screen = TerminalEnvScreen();
      expect(screen, isA<TerminalEnvScreen>());
    });

    test('can be const constructed with key', () {
      const screen = TerminalEnvScreen(key: Key('terminal-env'));
      expect(screen.key, const Key('terminal-env'));
    });

    test('is a StatelessWidget', () {
      const screen = TerminalEnvScreen();
      expect(screen, isA<StatelessWidget>());
    });

    test('static path is lowercase with hyphens', () {
      expect(TerminalEnvScreen.path, TerminalEnvScreen.path.toLowerCase());
      expect(TerminalEnvScreen.path, contains('-'));
    });

    test('static path does not start with slash (relative path)', () {
      expect(TerminalEnvScreen.path.startsWith('/'), isFalse);
    });

    test('static name matches SettingsScreenNames constant', () {
      expect(TerminalEnvScreen.name, equals(SettingsScreenNames.terminalEnv));
    });
  });
}
