import 'package:flutter/material.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';

/// Settings section for theme appearance (light/dark/system mode).
class BlocSettingsSectionAppearance {
  BlocSettingsSectionAppearance._();

  /// Builds a navigation tile for the appearance setting.
  ///
  /// Note: This reads from the DmThemeBloc at build time. Ensure a parent
  /// BlocBuilder wraps this for reactive updates.
  static SettingsTile tile({
    required BuildContext context,
    required void Function(BuildContext) onPressed,
  }) {
    final state = context.read<DmThemeBloc>().state;

    return SettingsTile.navigation(
      title: const Text('Appearance'),
      leading: state.themeMode.icon,
      value: Text(state.themeMode.title),
      onPressed: onPressed,
    );
  }

  /// Builds a full settings section for selecting theme mode.
  static SettingsSection buildSection(BuildContext context) {
    final themeBloc = context.read<DmThemeBloc>();

    return SettingsSection(
      title: const Text('Appearance'),
      tiles: <SettingsTile>[
        for (final mode in ThemeMode.values)
          SettingsTile(
            title: Text(mode.title),
            leading: mode.iconOutlined,
            trailing: BlocBuilder<DmThemeBloc, DmThemeState>(
              bloc: themeBloc,
              builder: (context, state) {
                return state.themeMode == mode
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : const SizedBox.shrink();
              },
            ),
            onPressed: (context) {
              themeBloc.add(DmSetThemeMode(mode));
            },
          ),
      ],
    );
  }
}
