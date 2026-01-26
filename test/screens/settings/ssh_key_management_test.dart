import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_terminal/screens/settings/_setting_config.dart';
import 'package:web_terminal/screens/settings/ssh_key_management.dart';
import 'package:web_terminal/screens/settings/settings_screen.dart';

void main() {
  group('SettingsSSHKey', () {
    test('has correct static name from SettingsScreenNames', () {
      expect(SettingsSSHKey.name, SettingsScreenNames.sshKeyManagement);
      expect(SettingsSSHKey.name, 'SSH Key Management');
    });

    test('has correct static path', () {
      expect(SettingsSSHKey.path, 'ssh_key_management');
    });

    test('has correct fullPath combining SettingsScreen.path', () {
      expect(SettingsSSHKey.fullPath, '${SettingsScreen.path}/${SettingsSSHKey.path}');
      expect(SettingsSSHKey.fullPath, '/settings/ssh_key_management');
    });

    test('can be const constructed', () {
      const screen = SettingsSSHKey();
      expect(screen, isA<SettingsSSHKey>());
    });

    test('can be const constructed with key', () {
      const screen = SettingsSSHKey(key: Key('ssh-key-management'));
      expect(screen.key, const Key('ssh-key-management'));
    });

    test('is a StatefulWidget', () {
      const screen = SettingsSSHKey();
      expect(screen, isA<StatefulWidget>());
    });

    test('static path uses underscores', () {
      expect(SettingsSSHKey.path, contains('_'));
    });

    test('static path does not start with slash (relative path)', () {
      expect(SettingsSSHKey.path.startsWith('/'), isFalse);
    });

    test('fullPath starts with slash (absolute path)', () {
      expect(SettingsSSHKey.fullPath.startsWith('/'), isTrue);
    });

    test('static name matches SettingsScreenNames constant', () {
      expect(SettingsSSHKey.name, equals(SettingsScreenNames.sshKeyManagement));
    });

    test('static path contains "ssh" and "key"', () {
      expect(SettingsSSHKey.path, contains('ssh'));
      expect(SettingsSSHKey.path, contains('key'));
    });

    test('creates state when createState is called', () {
      const screen = SettingsSSHKey();
      final state = screen.createState();
      expect(state, isNotNull);
      expect(state, isA<State<SettingsSSHKey>>());
    });
  });
}
