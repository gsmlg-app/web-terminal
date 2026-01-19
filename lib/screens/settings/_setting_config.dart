import 'package:terminal_settings/terminal_settings.dart';

/// Screen names for settings navigation
class SettingsScreenNames {
  static const settings = 'Settings';
  static const terminalEnv = 'Terminal Environment';
  static const hostManagement = 'SSH Host Management';
  static const sshKeyManagement = 'SSH Key Management';
  static const deviceInfo = 'Device Info';
  static const wifiInfo = 'Wifi Info';
  static const selectBrightness = 'Select Brightness';
  static const selectTheme = 'Select Theme';
  static const webServer = 'web-server';
}

/// Shared configuration for RootSettingList navigation
const rootSettingListConfig = RootSettingListConfig(
  terminalEnvScreenName: SettingsScreenNames.terminalEnv,
  hostScreenName: SettingsScreenNames.hostManagement,
  sshKeyScreenName: SettingsScreenNames.sshKeyManagement,
  deviceInfoScreenName: SettingsScreenNames.deviceInfo,
  wifiInfoScreenName: SettingsScreenNames.wifiInfo,
  selectBrightnessScreenName: SettingsScreenNames.selectBrightness,
  selectThemeScreenName: SettingsScreenNames.selectTheme,
  webServerScreenName: SettingsScreenNames.webServer,
);
