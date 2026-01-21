import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_settings/terminal_settings.dart';
import 'package:web_terminal/screens/settings/_setting_config.dart';

void main() {
  group('SettingsScreenNames', () {
    test('settings constant is defined', () {
      expect(SettingsScreenNames.settings, isNotNull);
      expect(SettingsScreenNames.settings, 'Settings');
    });

    test('terminalEnv constant is defined', () {
      expect(SettingsScreenNames.terminalEnv, isNotNull);
      expect(SettingsScreenNames.terminalEnv, 'Terminal Environment');
    });

    test('hostManagement constant is defined', () {
      expect(SettingsScreenNames.hostManagement, isNotNull);
      expect(SettingsScreenNames.hostManagement, 'SSH Host Management');
    });

    test('sshKeyManagement constant is defined', () {
      expect(SettingsScreenNames.sshKeyManagement, isNotNull);
      expect(SettingsScreenNames.sshKeyManagement, 'SSH Key Management');
    });

    test('deviceInfo constant is defined', () {
      expect(SettingsScreenNames.deviceInfo, isNotNull);
      expect(SettingsScreenNames.deviceInfo, 'Device Info');
    });

    test('wifiInfo constant is defined', () {
      expect(SettingsScreenNames.wifiInfo, isNotNull);
      expect(SettingsScreenNames.wifiInfo, 'Wifi Info');
    });

    test('selectBrightness constant is defined', () {
      expect(SettingsScreenNames.selectBrightness, isNotNull);
      expect(SettingsScreenNames.selectBrightness, 'Select Brightness');
    });

    test('selectTheme constant is defined', () {
      expect(SettingsScreenNames.selectTheme, isNotNull);
      expect(SettingsScreenNames.selectTheme, 'Select Theme');
    });

    test('webServer constant is defined', () {
      expect(SettingsScreenNames.webServer, isNotNull);
      expect(SettingsScreenNames.webServer, 'web-server');
    });

    test('shellProfiles constant is defined', () {
      expect(SettingsScreenNames.shellProfiles, isNotNull);
      expect(SettingsScreenNames.shellProfiles, 'Shell Profiles');
    });

    test('all screen names are unique', () {
      final names = [
        SettingsScreenNames.settings,
        SettingsScreenNames.terminalEnv,
        SettingsScreenNames.hostManagement,
        SettingsScreenNames.sshKeyManagement,
        SettingsScreenNames.deviceInfo,
        SettingsScreenNames.wifiInfo,
        SettingsScreenNames.selectBrightness,
        SettingsScreenNames.selectTheme,
        SettingsScreenNames.webServer,
        SettingsScreenNames.shellProfiles,
      ];
      expect(names.toSet().length, names.length,
          reason: 'All screen names should be unique');
    });
  });

  group('rootSettingListConfig', () {
    test('is a RootSettingListConfig', () {
      expect(rootSettingListConfig, isA<RootSettingListConfig>());
    });

    test('terminalEnvScreenName matches SettingsScreenNames', () {
      expect(rootSettingListConfig.terminalEnvScreenName,
          SettingsScreenNames.terminalEnv);
    });

    test('hostScreenName matches SettingsScreenNames', () {
      expect(rootSettingListConfig.hostScreenName,
          SettingsScreenNames.hostManagement);
    });

    test('sshKeyScreenName matches SettingsScreenNames', () {
      expect(rootSettingListConfig.sshKeyScreenName,
          SettingsScreenNames.sshKeyManagement);
    });

    test('deviceInfoScreenName matches SettingsScreenNames', () {
      expect(rootSettingListConfig.deviceInfoScreenName,
          SettingsScreenNames.deviceInfo);
    });

    test('wifiInfoScreenName matches SettingsScreenNames', () {
      expect(rootSettingListConfig.wifiInfoScreenName,
          SettingsScreenNames.wifiInfo);
    });

    test('selectBrightnessScreenName matches SettingsScreenNames', () {
      expect(rootSettingListConfig.selectBrightnessScreenName,
          SettingsScreenNames.selectBrightness);
    });

    test('selectThemeScreenName matches SettingsScreenNames', () {
      expect(rootSettingListConfig.selectThemeScreenName,
          SettingsScreenNames.selectTheme);
    });

    test('webServerScreenName matches SettingsScreenNames', () {
      expect(rootSettingListConfig.webServerScreenName,
          SettingsScreenNames.webServer);
    });

    test('shellProfilesScreenName matches SettingsScreenNames', () {
      expect(rootSettingListConfig.shellProfilesScreenName,
          SettingsScreenNames.shellProfiles);
    });
  });
}
