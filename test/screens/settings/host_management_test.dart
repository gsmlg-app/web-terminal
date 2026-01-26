import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_terminal/screens/settings/_setting_config.dart';
import 'package:web_terminal/screens/settings/host_management.dart';
import 'package:web_terminal/screens/settings/settings_screen.dart';

void main() {
  group('SettingsHost', () {
    test('has correct static name from SettingsScreenNames', () {
      expect(SettingsHost.name, SettingsScreenNames.hostManagement);
      expect(SettingsHost.name, 'SSH Host Management');
    });

    test('has correct static path', () {
      expect(SettingsHost.path, 'ssh_host_management');
    });

    test('has correct fullPath combining SettingsScreen.path', () {
      expect(SettingsHost.fullPath, '${SettingsScreen.path}/${SettingsHost.path}');
      expect(SettingsHost.fullPath, '/settings/ssh_host_management');
    });

    test('can be const constructed', () {
      const screen = SettingsHost();
      expect(screen, isA<SettingsHost>());
    });

    test('can be const constructed with key', () {
      const screen = SettingsHost(key: Key('host-management'));
      expect(screen.key, const Key('host-management'));
    });

    test('is a StatelessWidget', () {
      const screen = SettingsHost();
      expect(screen, isA<StatelessWidget>());
    });

    test('static path uses underscores', () {
      expect(SettingsHost.path, contains('_'));
    });

    test('static path does not start with slash (relative path)', () {
      expect(SettingsHost.path.startsWith('/'), isFalse);
    });

    test('fullPath starts with slash (absolute path)', () {
      expect(SettingsHost.fullPath.startsWith('/'), isTrue);
    });

    test('static name matches SettingsScreenNames constant', () {
      expect(SettingsHost.name, equals(SettingsScreenNames.hostManagement));
    });

    test('static path contains "ssh" and "host"', () {
      expect(SettingsHost.path, contains('ssh'));
      expect(SettingsHost.path, contains('host'));
    });
  });
}
