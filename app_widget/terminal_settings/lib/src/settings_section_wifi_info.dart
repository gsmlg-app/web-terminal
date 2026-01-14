import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

/// Settings section for displaying WiFi information.
///
/// Note: This is a placeholder implementation. For full WiFi information,
/// consider adding the `network_info_plus` package to get actual network details
/// like SSID, BSSID, IP address, etc.
class SettingsSectionWifiInfo {
  SettingsSectionWifiInfo._();

  /// Builds a settings section with WiFi information.
  static SettingsSection build(BuildContext context) {
    return SettingsSection(
      title: const Text('WiFi Information'),
      tiles: <SettingsTile>[
        SettingsTile(
          title: const Text('Network Status'),
          leading: const Icon(Icons.wifi),
          value: const Text('Connected'),
        ),
        SettingsTile(
          title: const Text('SSID'),
          leading: const Icon(Icons.wifi_lock),
          value: const Text('Not available'),
          description: const Text(
            'Add network_info_plus package for full WiFi details',
          ),
        ),
        SettingsTile(
          title: const Text('IP Address'),
          leading: const Icon(Icons.router),
          value: const Text('Not available'),
        ),
      ],
    );
  }
}
