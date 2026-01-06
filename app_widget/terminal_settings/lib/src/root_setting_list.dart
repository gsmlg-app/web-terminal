import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:theme_bloc/theme_bloc.dart';
import 'package:terminal_settings/src/bloc_settings_section_accent_color.dart';
import 'package:terminal_settings/src/bloc_settings_section_appearance.dart';
import 'package:app_locale/app_locale.dart';

/// Configuration for root settings list screen routing.
class RootSettingListConfig {
  /// Screen name for the host management screen.
  final String hostScreenName;

  /// Screen name for the SSH key management screen.
  final String sshKeyScreenName;

  /// Screen name for the device info screen.
  final String deviceInfoScreenName;

  /// Screen name for the wifi info screen.
  final String wifiInfoScreenName;

  /// Screen name for the brightness selection screen.
  final String selectBrightnessScreenName;

  /// Screen name for the theme selection screen.
  final String selectThemeScreenName;

  const RootSettingListConfig({
    required this.hostScreenName,
    required this.sshKeyScreenName,
    required this.deviceInfoScreenName,
    required this.wifiInfoScreenName,
    required this.selectBrightnessScreenName,
    required this.selectThemeScreenName,
  });
}

/// The main settings list widget displaying all setting categories.
class RootSettingList extends StatelessWidget {
  /// Configuration for screen navigation.
  final RootSettingListConfig config;

  const RootSettingList({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();

    return BlocBuilder<ThemeBloc, ThemeState>(
        bloc: themeBloc,
        builder: (context, state) {
          return SettingsList(
            sections: [
              SettingsSection(
                title: Text(context.l10n.smenuSSH),
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    title: Text(context.l10n.sshHost),
                    leading: const FaIcon(FontAwesomeIcons.server),
                    onPressed: (context) {
                      context.goNamed(config.hostScreenName);
                    },
                  ),
                  SettingsTile.navigation(
                    title: Text(context.l10n.sshKey),
                    leading: const Icon(Icons.vpn_key),
                    onPressed: (context) {
                      context.goNamed(config.sshKeyScreenName);
                    },
                  ),
                ],
              ),
              SettingsSection(
                title: const Text('Device'),
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    leading: const Icon(Icons.devices_rounded),
                    title: const Text('Device Info'),
                    onPressed: (context) {
                      context.goNamed(config.deviceInfoScreenName);
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.wifi_sharp),
                    title: const Text('Wifi Info'),
                    onPressed: (context) {
                      context.goNamed(config.wifiInfoScreenName);
                    },
                  ),
                ],
              ),
              SettingsSection(
                title: Text(context.l10n.smenuTheme),
                tiles: <SettingsTile>[
                  BlocSettingsSectionAppearance.tile(
                      context: context,
                      onPressed: (context) {
                        context.goNamed(config.selectBrightnessScreenName);
                      }),
                  BlocSettingsSectionAccentColor.tile(
                    context: context,
                    onPressed: (context) {
                      context.goNamed(config.selectThemeScreenName);
                    },
                  ),
                ],
              ),
            ],
          );
        });
  }
}
