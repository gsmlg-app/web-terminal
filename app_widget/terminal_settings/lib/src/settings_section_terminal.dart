import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:terminal_settings_bloc/terminal_settings_bloc.dart';

/// Available monospace font families for terminal.
const List<String> kTerminalFontFamilies = [
  'monospace',
  'Menlo',
  'Monaco',
  'Consolas',
  'Courier New',
  'Source Code Pro',
  'JetBrains Mono',
  'Fira Code',
];

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

        final maxShells = state is TerminalSettingsLoaded
            ? state.maxOpenShells
            : kTerminalDefaultMaxOpenShells;

        final fontSize = state is TerminalSettingsLoaded
            ? state.fontSize
            : kTerminalDefaultFontSize;

        final fontFamily = state is TerminalSettingsLoaded
            ? state.fontFamily
            : kTerminalDefaultFontFamily;

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
            SettingsTile(
              leading: const Icon(Icons.tab),
              title: const Text('Max Open Sessions'),
              description:
                  Text('$maxShells concurrent session${maxShells > 1 ? 's' : ''}'),
              trailing: DropdownButton<int>(
                value: maxShells,
                underline: const SizedBox(),
                items: [1, 3, 5, 10, 15, 20, 30, 50]
                    .map((value) => DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value'),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    context.read<TerminalSettingsBloc>().add(
                          TerminalSettingsUpdateMaxOpenShells(
                              maxOpenShells: value),
                        );
                  }
                },
              ),
            ),
            SettingsTile(
              leading: const Icon(Icons.format_size),
              title: const Text('Font Size'),
              description: Text('${fontSize.toInt()} px'),
              trailing: SizedBox(
                width: 200,
                child: Slider(
                  value: fontSize,
                  min: 8,
                  max: 32,
                  divisions: 24,
                  label: '${fontSize.toInt()} px',
                  onChanged: (value) {
                    context.read<TerminalSettingsBloc>().add(
                          TerminalSettingsUpdateFontSize(fontSize: value),
                        );
                  },
                ),
              ),
            ),
            SettingsTile(
              leading: const Icon(Icons.font_download),
              title: const Text('Font Family'),
              description: Text(fontFamily),
              trailing: DropdownButton<String>(
                value: kTerminalFontFamilies.contains(fontFamily)
                    ? fontFamily
                    : kTerminalFontFamilies.first,
                underline: const SizedBox(),
                items: kTerminalFontFamilies
                    .map((value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(fontFamily: value),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    context.read<TerminalSettingsBloc>().add(
                          TerminalSettingsUpdateFontFamily(fontFamily: value),
                        );
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
