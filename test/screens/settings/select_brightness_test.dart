import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_terminal/screens/settings/_setting_config.dart';
import 'package:web_terminal/screens/settings/select_brightness.dart';
import 'package:web_terminal/screens/settings/settings_screen.dart';

void main() {
  group('SettingsSelectBrightness', () {
    test('has correct static name from SettingsScreenNames', () {
      expect(SettingsSelectBrightness.name, SettingsScreenNames.selectBrightness);
      expect(SettingsSelectBrightness.name, 'Select Brightness');
    });

    test('has correct static path', () {
      expect(SettingsSelectBrightness.path, 'select_brightness');
    });

    test('has correct fullPath combining SettingsScreen.path', () {
      expect(SettingsSelectBrightness.fullPath, '${SettingsScreen.path}/${SettingsSelectBrightness.path}');
      expect(SettingsSelectBrightness.fullPath, '/settings/select_brightness');
    });

    test('can be const constructed', () {
      const screen = SettingsSelectBrightness();
      expect(screen, isA<SettingsSelectBrightness>());
    });

    test('can be const constructed with key', () {
      const screen = SettingsSelectBrightness(key: Key('brightness'));
      expect(screen.key, const Key('brightness'));
    });

    test('is a StatelessWidget', () {
      const screen = SettingsSelectBrightness();
      expect(screen, isA<StatelessWidget>());
    });

    test('static path uses underscores', () {
      expect(SettingsSelectBrightness.path, contains('_'));
    });

    test('static path does not start with slash (relative path)', () {
      expect(SettingsSelectBrightness.path.startsWith('/'), isFalse);
    });

    test('fullPath starts with slash (absolute path)', () {
      expect(SettingsSelectBrightness.fullPath.startsWith('/'), isTrue);
    });

    test('static name matches SettingsScreenNames constant', () {
      expect(SettingsSelectBrightness.name, equals(SettingsScreenNames.selectBrightness));
    });
  });
}
