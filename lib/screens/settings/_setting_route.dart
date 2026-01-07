import 'package:go_router/go_router.dart';
import 'package:web_terminal/screens/settings/device/device_info_screen.dart';
import 'package:web_terminal/screens/settings/device/wifi_info_screen.dart';
import 'package:web_terminal/screens/settings/host_management.dart';
import 'package:web_terminal/screens/settings/select_brightness.dart';
import 'package:web_terminal/screens/settings/select_theme.dart';
import 'package:web_terminal/screens/settings/settings_screen.dart';
import 'package:web_terminal/screens/settings/ssh_key_management.dart';
import 'package:web_terminal/screens/settings/web_server/web_server_screen.dart';

final settingRoute = GoRoute(
  name: SettingsScreen.name,
  path: SettingsScreen.path,
  pageBuilder: (context, state) {
    return NoTransitionPage<void>(
      key: state.pageKey,
      child: const SettingsScreen(),
    );
  },
  routes: [
    GoRoute(
      name: SettingsSelectBrightness.name,
      path: SettingsSelectBrightness.path,
      pageBuilder: (context, state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          child: const SettingsSelectBrightness(),
        );
      },
    ),
    GoRoute(
      name: SettingsSelectTheme.name,
      path: SettingsSelectTheme.path,
      pageBuilder: (context, state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          child: const SettingsSelectTheme(),
        );
      },
    ),
    GoRoute(
      name: DeviceInfoScreen.name,
      path: DeviceInfoScreen.path,
      pageBuilder: (context, state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          child: const DeviceInfoScreen(),
        );
      },
    ),
    GoRoute(
      name: WifiInfoScreen.name,
      path: WifiInfoScreen.path,
      pageBuilder: (context, state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          child: const WifiInfoScreen(),
        );
      },
    ),
    GoRoute(
      name: SettingsSSHKey.name,
      path: SettingsSSHKey.path,
      pageBuilder: (context, state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          child: const SettingsSSHKey(),
        );
      },
    ),
    GoRoute(
      name: SettingsHost.name,
      path: SettingsHost.path,
      pageBuilder: (context, state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          child: const SettingsHost(),
        );
      },
    ),
    GoRoute(
      name: WebServerScreen.name,
      path: WebServerScreen.path,
      pageBuilder: (context, state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          child: const WebServerScreen(),
        );
      },
    ),
  ],
);
