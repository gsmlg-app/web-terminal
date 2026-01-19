import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:terminal_settings_bloc/terminal_settings_bloc.dart';

/// Settings section for terminal configuration including environment variables.
class SettingsSectionTerminal extends AbstractSettingsSection {
  /// Screen name for terminal environment settings.
  final String envSettingsScreenName;

  /// Callback when environment settings tile is pressed.
  final void Function(BuildContext context) onEnvSettingsPressed;

  const SettingsSectionTerminal({
    super.key,
    required this.envSettingsScreenName,
    required this.onEnvSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TerminalSettingsBloc, TerminalSettingsState>(
      builder: (context, state) {
        final envCount = state is TerminalSettingsLoaded
            ? state.environmentVariables.length
            : 0;

        return SettingsSection(
          title: const Text('Terminal'),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: const Icon(Icons.settings_applications),
              title: const Text('Environment Variables'),
              description: Text(
                envCount > 0
                    ? '$envCount custom variable${envCount > 1 ? 's' : ''}'
                    : 'No custom variables',
              ),
              onPressed: onEnvSettingsPressed,
            ),
          ],
        );
      },
    );
  }
}
