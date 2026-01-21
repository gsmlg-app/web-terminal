import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_terminal/screens/settings/_setting_config.dart';
import 'package:web_terminal/screens/settings/select_theme.dart';
import 'package:web_terminal/screens/settings/settings_screen.dart';

void main() {
  group('SettingsSelectTheme', () {
    test('has correct static name from SettingsScreenNames', () {
      expect(SettingsSelectTheme.name, SettingsScreenNames.selectTheme);
      expect(SettingsSelectTheme.name, 'Select Theme');
    });

    test('has correct static path', () {
      expect(SettingsSelectTheme.path, 'select_theme');
    });

    test('has correct fullPath combining SettingsScreen.path', () {
      expect(SettingsSelectTheme.fullPath, '${SettingsScreen.path}/${SettingsSelectTheme.path}');
      expect(SettingsSelectTheme.fullPath, '/settings/select_theme');
    });

    test('can be const constructed', () {
      const screen = SettingsSelectTheme();
      expect(screen, isA<SettingsSelectTheme>());
    });

    test('can be const constructed with key', () {
      const screen = SettingsSelectTheme(key: Key('theme'));
      expect(screen.key, const Key('theme'));
    });

    test('is a StatelessWidget', () {
      const screen = SettingsSelectTheme();
      expect(screen, isA<StatelessWidget>());
    });

    test('static path uses underscores', () {
      expect(SettingsSelectTheme.path, contains('_'));
    });

    test('static path does not start with slash (relative path)', () {
      expect(SettingsSelectTheme.path.startsWith('/'), isFalse);
    });

    test('fullPath starts with slash (absolute path)', () {
      expect(SettingsSelectTheme.fullPath.startsWith('/'), isTrue);
    });

    test('static name matches SettingsScreenNames constant', () {
      expect(SettingsSelectTheme.name, equals(SettingsScreenNames.selectTheme));
    });
  });
}
