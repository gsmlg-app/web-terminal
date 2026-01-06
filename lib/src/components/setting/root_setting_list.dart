import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:app_theme/app_theme.dart';
import 'package:web_terminal/screens/settings/device/device_info_screen.dart';
import 'package:web_terminal/screens/settings/device/wifi_info_screen.dart';
import 'package:web_terminal/screens/settings/host_management.dart';
import 'package:web_terminal/screens/settings/select_brightness.dart';
import 'package:web_terminal/screens/settings/select_theme.dart';
import 'package:web_terminal/screens/settings/ssh_key_management.dart';
import 'package:web_terminal/src/extensions/buildcontext/l10n.dart';

class RootSettingList extends StatelessWidget {
  const RootSettingList({super.key});

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
                      context.goNamed(SettingsHost.name);
                    },
                  ),
                  SettingsTile.navigation(
                    title: Text(context.l10n.sshKey),
                    leading: const Icon(Icons.vpn_key),
                    onPressed: (context) {
                      context.goNamed(SettingsSSHKey.name);
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
                      context.goNamed(DeviceInfoScreen.name);
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.wifi_sharp),
                    title: const Text('Wifi Info'),
                    onPressed: (context) {
                      context.goNamed(WifiInfoScreen.name);
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
                        context.goNamed(SettingsSelectBrightness.name);
                      }),
                  BlocSettingsSectionAccentColor.tile(
                    context: context,
                    onPressed: (context) {
                      context.goNamed(SettingsSelectTheme.name);
                    },
                  ),
                ],
              ),
            ],
          );
        });
  }
}
