import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:web_terminal/screens/settings/_setting_route.dart';
import 'package:web_terminal/screens/settings/settings_screen.dart';
import 'package:web_terminal/screens/settings/device/device_info_screen.dart';
import 'package:web_terminal/screens/settings/device/wifi_info_screen.dart';
import 'package:web_terminal/screens/settings/host_management.dart';
import 'package:web_terminal/screens/settings/select_brightness.dart';
import 'package:web_terminal/screens/settings/select_theme.dart';
import 'package:web_terminal/screens/settings/shell_profile_screen.dart';
import 'package:web_terminal/screens/settings/ssh_key_management.dart';
import 'package:web_terminal/screens/settings/terminal_env_screen.dart';
import 'package:web_terminal/screens/settings/web_server/web_server_screen.dart';

void main() {
  group('settingRoute', () {
    test('is a GoRoute', () {
      expect(settingRoute, isA<GoRoute>());
    });

    test('has correct name from SettingsScreen', () {
      expect(settingRoute.name, SettingsScreen.name);
    });

    test('has correct path from SettingsScreen', () {
      expect(settingRoute.path, SettingsScreen.path);
    });

    test('has pageBuilder defined', () {
      expect(settingRoute.pageBuilder, isNotNull);
    });

    test('has 9 nested routes', () {
      expect(settingRoute.routes.length, 9);
    });
  });

  group('settingRoute nested routes', () {
    late List<GoRoute> nestedRoutes;

    setUp(() {
      nestedRoutes = settingRoute.routes.cast<GoRoute>();
    });

    test('contains TerminalEnvScreen route', () {
      final route = nestedRoutes.firstWhere(
        (r) => r.name == TerminalEnvScreen.name,
        orElse: () => throw Exception('TerminalEnvScreen route not found'),
      );
      expect(route.path, TerminalEnvScreen.path);
      expect(route.pageBuilder, isNotNull);
    });

    test('contains SettingsSelectBrightness route', () {
      final route = nestedRoutes.firstWhere(
        (r) => r.name == SettingsSelectBrightness.name,
        orElse: () =>
            throw Exception('SettingsSelectBrightness route not found'),
      );
      expect(route.path, SettingsSelectBrightness.path);
      expect(route.pageBuilder, isNotNull);
    });

    test('contains SettingsSelectTheme route', () {
      final route = nestedRoutes.firstWhere(
        (r) => r.name == SettingsSelectTheme.name,
        orElse: () => throw Exception('SettingsSelectTheme route not found'),
      );
      expect(route.path, SettingsSelectTheme.path);
      expect(route.pageBuilder, isNotNull);
    });

    test('contains DeviceInfoScreen route', () {
      final route = nestedRoutes.firstWhere(
        (r) => r.name == DeviceInfoScreen.name,
        orElse: () => throw Exception('DeviceInfoScreen route not found'),
      );
      expect(route.path, DeviceInfoScreen.path);
      expect(route.pageBuilder, isNotNull);
    });

    test('contains WifiInfoScreen route', () {
      final route = nestedRoutes.firstWhere(
        (r) => r.name == WifiInfoScreen.name,
        orElse: () => throw Exception('WifiInfoScreen route not found'),
      );
      expect(route.path, WifiInfoScreen.path);
      expect(route.pageBuilder, isNotNull);
    });

    test('contains SettingsSSHKey route', () {
      final route = nestedRoutes.firstWhere(
        (r) => r.name == SettingsSSHKey.name,
        orElse: () => throw Exception('SettingsSSHKey route not found'),
      );
      expect(route.path, SettingsSSHKey.path);
      expect(route.pageBuilder, isNotNull);
    });

    test('contains SettingsHost route', () {
      final route = nestedRoutes.firstWhere(
        (r) => r.name == SettingsHost.name,
        orElse: () => throw Exception('SettingsHost route not found'),
      );
      expect(route.path, SettingsHost.path);
      expect(route.pageBuilder, isNotNull);
    });

    test('contains WebServerScreen route', () {
      final route = nestedRoutes.firstWhere(
        (r) => r.name == WebServerScreen.name,
        orElse: () => throw Exception('WebServerScreen route not found'),
      );
      expect(route.path, WebServerScreen.path);
      expect(route.pageBuilder, isNotNull);
    });

    test('contains ShellProfileScreen route', () {
      final route = nestedRoutes.firstWhere(
        (r) => r.name == ShellProfileScreen.name,
        orElse: () => throw Exception('ShellProfileScreen route not found'),
      );
      expect(route.path, ShellProfileScreen.path);
      expect(route.pageBuilder, isNotNull);
    });

    test('all nested routes have unique names', () {
      final names = nestedRoutes.map((r) => r.name).toList();
      expect(names.toSet().length, names.length,
          reason: 'All route names should be unique');
    });

    test('all nested routes have unique paths', () {
      final paths = nestedRoutes.map((r) => r.path).toList();
      expect(paths.toSet().length, paths.length,
          reason: 'All route paths should be unique');
    });

    test('no nested route path starts with slash (relative paths)', () {
      for (final route in nestedRoutes) {
        expect(route.path.startsWith('/'), isFalse,
            reason: 'Nested route ${route.name} should have relative path');
      }
    });
  });
}
