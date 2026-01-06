import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_settings/terminal_settings.dart';

void main() {
  group('terminal_settings', () {
    test('exports are available', () {
      // Verify that the main exports are accessible
      expect(Destinations, isNotNull);
      expect(BlocSettingsSectionAccentColor, isNotNull);
      expect(BlocSettingsSectionAppearance, isNotNull);
      expect(RootSettingList, isNotNull);
      expect(RootSettingListConfig, isNotNull);
      expect(SettingsSectionDeviceInfo, isNotNull);
      expect(SettingsSectionWifiInfo, isNotNull);
    });

    test('Destinations constants are defined', () {
      expect(Destinations.terminalScreenName, equals('terminal'));
      expect(Destinations.settingsScreenName, equals('settings'));
    });
  });
}
