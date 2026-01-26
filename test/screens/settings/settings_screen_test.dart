import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_settings/terminal_settings.dart';
import 'package:web_terminal/screens/settings/settings_screen.dart';
import 'package:web_terminal/screens/settings/_setting_config.dart';

void main() {
  group('SettingsScreen', () {
    test('has correct static name', () {
      expect(SettingsScreen.name, 'Settings');
    });

    test('has correct static path', () {
      expect(SettingsScreen.path, '/settings');
    });

    test('can be const constructed', () {
      const screen = SettingsScreen();
      expect(screen, isA<SettingsScreen>());
    });

    test('can be const constructed with key', () {
      const screen = SettingsScreen(key: Key('settings'));
      expect(screen.key, const Key('settings'));
    });
  });

  group('SettingsScreenNames', () {
    test('settings constant', () {
      expect(SettingsScreenNames.settings, 'Settings');
    });

    test('terminalEnv constant', () {
      expect(SettingsScreenNames.terminalEnv, 'Terminal Environment');
    });

    test('hostManagement constant', () {
      expect(SettingsScreenNames.hostManagement, 'SSH Host Management');
    });

    test('sshKeyManagement constant', () {
      expect(SettingsScreenNames.sshKeyManagement, 'SSH Key Management');
    });

    test('deviceInfo constant', () {
      expect(SettingsScreenNames.deviceInfo, 'Device Info');
    });

    test('wifiInfo constant', () {
      expect(SettingsScreenNames.wifiInfo, 'Wifi Info');
    });

    test('selectBrightness constant', () {
      expect(SettingsScreenNames.selectBrightness, 'Select Brightness');
    });

    test('selectTheme constant', () {
      expect(SettingsScreenNames.selectTheme, 'Select Theme');
    });

    test('webServer constant', () {
      expect(SettingsScreenNames.webServer, 'web-server');
    });

    test('shellProfiles constant', () {
      expect(SettingsScreenNames.shellProfiles, 'Shell Profiles');
    });
  });

  group('rootSettingListConfig', () {
    test('is a const RootSettingListConfig', () {
      expect(rootSettingListConfig, isA<RootSettingListConfig>());
    });

    test('has correct terminalEnvScreenName', () {
      expect(
        rootSettingListConfig.terminalEnvScreenName,
        SettingsScreenNames.terminalEnv,
      );
    });

    test('has correct hostScreenName', () {
      expect(
        rootSettingListConfig.hostScreenName,
        SettingsScreenNames.hostManagement,
      );
    });

    test('has correct sshKeyScreenName', () {
      expect(
        rootSettingListConfig.sshKeyScreenName,
        SettingsScreenNames.sshKeyManagement,
      );
    });

    test('has correct deviceInfoScreenName', () {
      expect(
        rootSettingListConfig.deviceInfoScreenName,
        SettingsScreenNames.deviceInfo,
      );
    });

    test('has correct wifiInfoScreenName', () {
      expect(
        rootSettingListConfig.wifiInfoScreenName,
        SettingsScreenNames.wifiInfo,
      );
    });

    test('has correct selectBrightnessScreenName', () {
      expect(
        rootSettingListConfig.selectBrightnessScreenName,
        SettingsScreenNames.selectBrightness,
      );
    });

    test('has correct selectThemeScreenName', () {
      expect(
        rootSettingListConfig.selectThemeScreenName,
        SettingsScreenNames.selectTheme,
      );
    });

    test('has correct webServerScreenName', () {
      expect(
        rootSettingListConfig.webServerScreenName,
        SettingsScreenNames.webServer,
      );
    });

    test('has correct shellProfilesScreenName', () {
      expect(
        rootSettingListConfig.shellProfilesScreenName,
        SettingsScreenNames.shellProfiles,
      );
    });
  });
}
