import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_terminal/screens/settings/_setting_config.dart';
import 'package:web_terminal/screens/settings/device/wifi_info_screen.dart';

void main() {
  group('WifiInfoScreen', () {
    test('has correct static name from SettingsScreenNames', () {
      expect(WifiInfoScreen.name, SettingsScreenNames.wifiInfo);
      expect(WifiInfoScreen.name, 'Wifi Info');
    });

    test('has correct static path', () {
      expect(WifiInfoScreen.path, 'wifi-info');
    });

    test('can be const constructed', () {
      const screen = WifiInfoScreen();
      expect(screen, isA<WifiInfoScreen>());
    });

    test('can be const constructed with key', () {
      const screen = WifiInfoScreen(key: Key('wifi-info'));
      expect(screen.key, const Key('wifi-info'));
    });

    test('is a StatelessWidget', () {
      const screen = WifiInfoScreen();
      expect(screen, isA<StatelessWidget>());
    });

    test('static path is lowercase with hyphens', () {
      expect(WifiInfoScreen.path, WifiInfoScreen.path.toLowerCase());
      expect(WifiInfoScreen.path, contains('-'));
    });

    test('static path does not start with slash (relative path)', () {
      expect(WifiInfoScreen.path.startsWith('/'), isFalse);
    });

    test('static name matches SettingsScreenNames constant', () {
      expect(WifiInfoScreen.name, equals(SettingsScreenNames.wifiInfo));
    });
  });
}
