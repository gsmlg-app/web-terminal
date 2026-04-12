import 'package:flutter/material.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';

/// Settings section for theme accent color selection.
class BlocSettingsSectionAccentColor {
  BlocSettingsSectionAccentColor._();

  /// Builds a navigation tile for the accent color setting.
  ///
  /// Note: This reads from the DmThemeBloc at build time. Ensure a parent
  /// BlocBuilder wraps this for reactive updates.
  static SettingsTile tile({
    required BuildContext context,
    required void Function(BuildContext) onPressed,
  }) {
    final state = context.read<DmThemeBloc>().state;

    return SettingsTile.navigation(
      title: const Text('Accent Color'),
      leading: Icon(
        Icons.palette,
        color: state.entry.light.colorScheme.primary,
      ),
      value: Text(state.themeName),
      onPressed: onPressed,
    );
  }

  /// Builds a full settings section for selecting accent color theme.
  static SettingsSection buildSection(BuildContext context) {
    final themeBloc = context.read<DmThemeBloc>();

    return SettingsSection(
      title: const Text('Accent Color'),
      tiles: <SettingsTile>[
        for (final entry in DmThemeData.themes)
          SettingsTile(
            title: Text(entry.name),
            leading: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: entry.light.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            trailing: BlocBuilder<DmThemeBloc, DmThemeState>(
              bloc: themeBloc,
              builder: (context, state) {
                return state.themeName == entry.name
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : const SizedBox.shrink();
              },
            ),
            onPressed: (context) {
              themeBloc.add(DmSetTheme(entry.name));
            },
          ),
      ],
    );
  }
}
