import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

/// Settings section for displaying device information.
class SettingsSectionDeviceInfo {
  SettingsSectionDeviceInfo._();

  /// Builds a settings section with device information.
  static SettingsSection build(BuildContext context) {
    final deviceInfo = _getDeviceInfo();

    return SettingsSection(
      title: const Text('Device Information'),
      tiles: <SettingsTile>[
        SettingsTile(
          title: const Text('Platform'),
          leading: const Icon(Icons.phone_android),
          value: Text(deviceInfo['platform'] ?? 'Unknown'),
        ),
        SettingsTile(
          title: const Text('Operating System'),
          leading: const Icon(Icons.computer),
          value: Text(deviceInfo['operatingSystem'] ?? 'Unknown'),
        ),
        SettingsTile(
          title: const Text('OS Version'),
          leading: const Icon(Icons.info_outline),
          value: Text(deviceInfo['operatingSystemVersion'] ?? 'Unknown'),
        ),
        SettingsTile(
          title: const Text('Locale'),
          leading: const Icon(Icons.language),
          value: Text(deviceInfo['locale'] ?? 'Unknown'),
        ),
        SettingsTile(
          title: const Text('Number of Processors'),
          leading: const Icon(Icons.memory),
          value: Text(deviceInfo['numberOfProcessors'] ?? 'Unknown'),
        ),
      ],
    );
  }

  static Map<String, String> _getDeviceInfo() {
    if (kIsWeb) {
      return {
        'platform': 'Web',
        'operatingSystem': 'Browser',
        'operatingSystemVersion': 'N/A',
        'locale': 'N/A',
        'numberOfProcessors': 'N/A',
      };
    }

    return {
      'platform': _getPlatformName(),
      'operatingSystem': Platform.operatingSystem,
      'operatingSystemVersion': Platform.operatingSystemVersion,
      'locale': Platform.localeName,
      'numberOfProcessors': Platform.numberOfProcessors.toString(),
    };
  }

  static String _getPlatformName() {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isFuchsia) return 'Fuchsia';
    return 'Unknown';
  }
}
