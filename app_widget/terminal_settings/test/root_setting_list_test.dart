import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_settings/terminal_settings.dart';

void main() {
  group('RootSettingListConfig', () {
    group('constructor', () {
      test('creates with all required parameters', () {
        final config = RootSettingListConfig(
          terminalEnvScreenName: 'terminal_env',
          hostScreenName: 'hosts',
          sshKeyScreenName: 'ssh_keys',
          deviceInfoScreenName: 'device_info',
          wifiInfoScreenName: 'wifi_info',
          selectBrightnessScreenName: 'brightness',
          selectThemeScreenName: 'theme',
          webServerScreenName: 'web_server',
        );

        expect(config.terminalEnvScreenName, 'terminal_env');
        expect(config.hostScreenName, 'hosts');
        expect(config.sshKeyScreenName, 'ssh_keys');
        expect(config.deviceInfoScreenName, 'device_info');
        expect(config.wifiInfoScreenName, 'wifi_info');
        expect(config.selectBrightnessScreenName, 'brightness');
        expect(config.selectThemeScreenName, 'theme');
        expect(config.webServerScreenName, 'web_server');
      });

      test('shellProfilesScreenName defaults to null', () {
        final config = RootSettingListConfig(
          terminalEnvScreenName: 'terminal_env',
          hostScreenName: 'hosts',
          sshKeyScreenName: 'ssh_keys',
          deviceInfoScreenName: 'device_info',
          wifiInfoScreenName: 'wifi_info',
          selectBrightnessScreenName: 'brightness',
          selectThemeScreenName: 'theme',
          webServerScreenName: 'web_server',
        );

        expect(config.shellProfilesScreenName, isNull);
      });

      test('shellProfilesScreenName can be set', () {
        final config = RootSettingListConfig(
          terminalEnvScreenName: 'terminal_env',
          hostScreenName: 'hosts',
          sshKeyScreenName: 'ssh_keys',
          deviceInfoScreenName: 'device_info',
          wifiInfoScreenName: 'wifi_info',
          selectBrightnessScreenName: 'brightness',
          selectThemeScreenName: 'theme',
          webServerScreenName: 'web_server',
          shellProfilesScreenName: 'shell_profiles',
        );

        expect(config.shellProfilesScreenName, 'shell_profiles');
      });

      test('is const constructible', () {
        const config = RootSettingListConfig(
          terminalEnvScreenName: 'a',
          hostScreenName: 'b',
          sshKeyScreenName: 'c',
          deviceInfoScreenName: 'd',
          wifiInfoScreenName: 'e',
          selectBrightnessScreenName: 'f',
          selectThemeScreenName: 'g',
          webServerScreenName: 'h',
        );

        expect(config, isA<RootSettingListConfig>());
      });
    });

    group('properties', () {
      test('terminalEnvScreenName is accessible', () {
        final config = RootSettingListConfig(
          terminalEnvScreenName: 'test_terminal_env',
          hostScreenName: 'hosts',
          sshKeyScreenName: 'ssh_keys',
          deviceInfoScreenName: 'device_info',
          wifiInfoScreenName: 'wifi_info',
          selectBrightnessScreenName: 'brightness',
          selectThemeScreenName: 'theme',
          webServerScreenName: 'web_server',
        );

        expect(config.terminalEnvScreenName, 'test_terminal_env');
      });

      test('hostScreenName is accessible', () {
        final config = RootSettingListConfig(
          terminalEnvScreenName: 'terminal_env',
          hostScreenName: 'test_hosts',
          sshKeyScreenName: 'ssh_keys',
          deviceInfoScreenName: 'device_info',
          wifiInfoScreenName: 'wifi_info',
          selectBrightnessScreenName: 'brightness',
          selectThemeScreenName: 'theme',
          webServerScreenName: 'web_server',
        );

        expect(config.hostScreenName, 'test_hosts');
      });

      test('sshKeyScreenName is accessible', () {
        final config = RootSettingListConfig(
          terminalEnvScreenName: 'terminal_env',
          hostScreenName: 'hosts',
          sshKeyScreenName: 'test_ssh_keys',
          deviceInfoScreenName: 'device_info',
          wifiInfoScreenName: 'wifi_info',
          selectBrightnessScreenName: 'brightness',
          selectThemeScreenName: 'theme',
          webServerScreenName: 'web_server',
        );

        expect(config.sshKeyScreenName, 'test_ssh_keys');
      });

      test('deviceInfoScreenName is accessible', () {
        final config = RootSettingListConfig(
          terminalEnvScreenName: 'terminal_env',
          hostScreenName: 'hosts',
          sshKeyScreenName: 'ssh_keys',
          deviceInfoScreenName: 'test_device_info',
          wifiInfoScreenName: 'wifi_info',
          selectBrightnessScreenName: 'brightness',
          selectThemeScreenName: 'theme',
          webServerScreenName: 'web_server',
        );

        expect(config.deviceInfoScreenName, 'test_device_info');
      });

      test('wifiInfoScreenName is accessible', () {
        final config = RootSettingListConfig(
          terminalEnvScreenName: 'terminal_env',
          hostScreenName: 'hosts',
          sshKeyScreenName: 'ssh_keys',
          deviceInfoScreenName: 'device_info',
          wifiInfoScreenName: 'test_wifi_info',
          selectBrightnessScreenName: 'brightness',
          selectThemeScreenName: 'theme',
          webServerScreenName: 'web_server',
        );

        expect(config.wifiInfoScreenName, 'test_wifi_info');
      });

      test('selectBrightnessScreenName is accessible', () {
        final config = RootSettingListConfig(
          terminalEnvScreenName: 'terminal_env',
          hostScreenName: 'hosts',
          sshKeyScreenName: 'ssh_keys',
          deviceInfoScreenName: 'device_info',
          wifiInfoScreenName: 'wifi_info',
          selectBrightnessScreenName: 'test_brightness',
          selectThemeScreenName: 'theme',
          webServerScreenName: 'web_server',
        );

        expect(config.selectBrightnessScreenName, 'test_brightness');
      });

      test('selectThemeScreenName is accessible', () {
        final config = RootSettingListConfig(
          terminalEnvScreenName: 'terminal_env',
          hostScreenName: 'hosts',
          sshKeyScreenName: 'ssh_keys',
          deviceInfoScreenName: 'device_info',
          wifiInfoScreenName: 'wifi_info',
          selectBrightnessScreenName: 'brightness',
          selectThemeScreenName: 'test_theme',
          webServerScreenName: 'web_server',
        );

        expect(config.selectThemeScreenName, 'test_theme');
      });

      test('webServerScreenName is accessible', () {
        final config = RootSettingListConfig(
          terminalEnvScreenName: 'terminal_env',
          hostScreenName: 'hosts',
          sshKeyScreenName: 'ssh_keys',
          deviceInfoScreenName: 'device_info',
          wifiInfoScreenName: 'wifi_info',
          selectBrightnessScreenName: 'brightness',
          selectThemeScreenName: 'theme',
          webServerScreenName: 'test_web_server',
        );

        expect(config.webServerScreenName, 'test_web_server');
      });
    });

    group('all properties unique', () {
      test('all required screen names are unique', () {
        final config = RootSettingListConfig(
          terminalEnvScreenName: 'terminal_env',
          hostScreenName: 'hosts',
          sshKeyScreenName: 'ssh_keys',
          deviceInfoScreenName: 'device_info',
          wifiInfoScreenName: 'wifi_info',
          selectBrightnessScreenName: 'brightness',
          selectThemeScreenName: 'theme',
          webServerScreenName: 'web_server',
        );

        final names = {
          config.terminalEnvScreenName,
          config.hostScreenName,
          config.sshKeyScreenName,
          config.deviceInfoScreenName,
          config.wifiInfoScreenName,
          config.selectBrightnessScreenName,
          config.selectThemeScreenName,
          config.webServerScreenName,
        };

        expect(names.length, 8); // All unique
      });
    });
  });

  group('RootSettingList', () {
    group('constructor', () {
      test('is const constructible', () {
        const config = RootSettingListConfig(
          terminalEnvScreenName: 'a',
          hostScreenName: 'b',
          sshKeyScreenName: 'c',
          deviceInfoScreenName: 'd',
          wifiInfoScreenName: 'e',
          selectBrightnessScreenName: 'f',
          selectThemeScreenName: 'g',
          webServerScreenName: 'h',
        );
        const widget = RootSettingList(config: config);

        expect(widget, isA<RootSettingList>());
      });

      test('stores config', () {
        final config = RootSettingListConfig(
          terminalEnvScreenName: 'terminal_env',
          hostScreenName: 'hosts',
          sshKeyScreenName: 'ssh_keys',
          deviceInfoScreenName: 'device_info',
          wifiInfoScreenName: 'wifi_info',
          selectBrightnessScreenName: 'brightness',
          selectThemeScreenName: 'theme',
          webServerScreenName: 'web_server',
        );
        final widget = RootSettingList(config: config);

        expect(widget.config, config);
      });

      test('extends StatelessWidget', () {
        const config = RootSettingListConfig(
          terminalEnvScreenName: 'a',
          hostScreenName: 'b',
          sshKeyScreenName: 'c',
          deviceInfoScreenName: 'd',
          wifiInfoScreenName: 'e',
          selectBrightnessScreenName: 'f',
          selectThemeScreenName: 'g',
          webServerScreenName: 'h',
        );
        const widget = RootSettingList(config: config);

        expect(widget, isA<StatelessWidget>());
      });

      test('supports key parameter', () {
        final key = UniqueKey();
        final config = RootSettingListConfig(
          terminalEnvScreenName: 'terminal_env',
          hostScreenName: 'hosts',
          sshKeyScreenName: 'ssh_keys',
          deviceInfoScreenName: 'device_info',
          wifiInfoScreenName: 'wifi_info',
          selectBrightnessScreenName: 'brightness',
          selectThemeScreenName: 'theme',
          webServerScreenName: 'web_server',
        );
        final widget = RootSettingList(key: key, config: config);

        expect(widget.key, key);
      });
    });

    group('config access', () {
      test('config property returns provided config', () {
        final config = RootSettingListConfig(
          terminalEnvScreenName: 'env_screen',
          hostScreenName: 'host_screen',
          sshKeyScreenName: 'key_screen',
          deviceInfoScreenName: 'info_screen',
          wifiInfoScreenName: 'wifi_screen',
          selectBrightnessScreenName: 'bright_screen',
          selectThemeScreenName: 'theme_screen',
          webServerScreenName: 'server_screen',
        );
        final widget = RootSettingList(config: config);

        expect(widget.config.terminalEnvScreenName, 'env_screen');
        expect(widget.config.hostScreenName, 'host_screen');
        expect(widget.config.sshKeyScreenName, 'key_screen');
        expect(widget.config.deviceInfoScreenName, 'info_screen');
        expect(widget.config.wifiInfoScreenName, 'wifi_screen');
        expect(widget.config.selectBrightnessScreenName, 'bright_screen');
        expect(widget.config.selectThemeScreenName, 'theme_screen');
        expect(widget.config.webServerScreenName, 'server_screen');
      });

      test('config with shellProfilesScreenName', () {
        final config = RootSettingListConfig(
          terminalEnvScreenName: 'env_screen',
          hostScreenName: 'host_screen',
          sshKeyScreenName: 'key_screen',
          deviceInfoScreenName: 'info_screen',
          wifiInfoScreenName: 'wifi_screen',
          selectBrightnessScreenName: 'bright_screen',
          selectThemeScreenName: 'theme_screen',
          webServerScreenName: 'server_screen',
          shellProfilesScreenName: 'profiles_screen',
        );
        final widget = RootSettingList(config: config);

        expect(widget.config.shellProfilesScreenName, 'profiles_screen');
      });
    });
  });
}
