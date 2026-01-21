import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_terminal/screens/settings/_setting_config.dart';
import 'package:web_terminal/screens/settings/device/device_info_screen.dart';

void main() {
  group('DeviceInfoScreen', () {
    test('has correct static name from SettingsScreenNames', () {
      expect(DeviceInfoScreen.name, SettingsScreenNames.deviceInfo);
      expect(DeviceInfoScreen.name, 'Device Info');
    });

    test('has correct static path', () {
      expect(DeviceInfoScreen.path, 'device-info');
    });

    test('can be const constructed', () {
      const screen = DeviceInfoScreen();
      expect(screen, isA<DeviceInfoScreen>());
    });

    test('can be const constructed with key', () {
      const screen = DeviceInfoScreen(key: Key('device-info'));
      expect(screen.key, const Key('device-info'));
    });

    test('is a StatelessWidget', () {
      const screen = DeviceInfoScreen();
      expect(screen, isA<StatelessWidget>());
    });

    test('static path is lowercase with hyphens', () {
      expect(DeviceInfoScreen.path, DeviceInfoScreen.path.toLowerCase());
      expect(DeviceInfoScreen.path, contains('-'));
    });

    test('static path does not start with slash (relative path)', () {
      expect(DeviceInfoScreen.path.startsWith('/'), isFalse);
    });

    test('static name matches SettingsScreenNames constant', () {
      expect(DeviceInfoScreen.name, equals(SettingsScreenNames.deviceInfo));
    });
  });
}
