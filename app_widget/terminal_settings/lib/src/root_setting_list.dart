import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:theme_bloc/theme_bloc.dart';
import 'package:terminal_settings/src/bloc_settings_section_accent_color.dart';
import 'package:terminal_settings/src/bloc_settings_section_appearance.dart';
import 'package:terminal_settings/src/settings_section_terminal.dart';
import 'package:app_locale/app_locale.dart';
import 'package:web_session_bloc/web_session_bloc.dart';

/// Configuration for root settings list screen routing.
class RootSettingListConfig {
  /// Screen name for the terminal environment settings screen.
  final String terminalEnvScreenName;

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

  /// Screen name for the web server settings screen.
  final String webServerScreenName;

  /// Screen name for the shell profiles settings screen (optional).
  final String? shellProfilesScreenName;

  const RootSettingListConfig({
    required this.terminalEnvScreenName,
    required this.hostScreenName,
    required this.sshKeyScreenName,
    required this.deviceInfoScreenName,
    required this.wifiInfoScreenName,
    required this.selectBrightnessScreenName,
    required this.selectThemeScreenName,
    required this.webServerScreenName,
    this.shellProfilesScreenName,
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
              SettingsSectionTerminal(
                envSettingsScreenName: config.terminalEnvScreenName,
                onEnvSettingsPressed: (context) {
                  context.goNamed(config.terminalEnvScreenName);
                },
                onShellProfilesPressed: config.shellProfilesScreenName != null
                    ? (context) {
                        context.goNamed(config.shellProfilesScreenName!);
                      }
                    : null,
              ),
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
              _WebServerSection(
                webServerScreenName: config.webServerScreenName,
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

/// Web server settings section that rebuilds when server state changes.
class _WebServerSection extends AbstractSettingsSection {
  final String webServerScreenName;

  const _WebServerSection({required this.webServerScreenName});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WebSessionBloc, WebSessionState>(
      builder: (context, webState) {
        return SettingsSection(
          title: const Text('Web Server'),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: Icon(
                Icons.public,
                color: webState.serverRunning ? Colors.green : null,
              ),
              title: const Text('Web Server'),
              description: Text(
                webState.serverRunning
                    ? 'Running on port ${webState.serverPort}'
                    : 'Not running',
              ),
              onPressed: (context) {
                context.goNamed(webServerScreenName);
              },
            ),
          ],
        );
      },
    );
  }
}
