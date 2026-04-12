import 'package:flutter/material.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:app_theme/app_theme.dart';
import 'package:theme_bloc/theme_bloc.dart';

/// Settings section for theme accent color selection.
class BlocSettingsSectionAccentColor {
  BlocSettingsSectionAccentColor._();

  /// Builds a navigation tile for the accent color setting.
  ///
  /// Note: This reads from the ThemeBloc at build time. Ensure a parent
  /// BlocBuilder wraps this for reactive updates.
  static SettingsTile tile({
    required BuildContext context,
    required void Function(BuildContext) onPressed,
  }) {
    final state = context.read<ThemeBloc>().state;

    return SettingsTile.navigation(
      title: const Text('Accent Color'),
      leading: Icon(
        Icons.palette,
        color: state.theme.lightTheme.colorScheme.primary,
      ),
      value: Text(state.theme.name),
      onPressed: onPressed,
    );
  }

  /// Builds a full settings section for selecting accent color theme.
  static SettingsSection buildSection(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();

    return SettingsSection(
      title: const Text('Accent Color'),
      tiles: <SettingsTile>[
        for (final theme in themeList)
          SettingsTile(
            title: Text(theme.name),
            leading: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: theme.lightTheme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            trailing: BlocBuilder<ThemeBloc, ThemeState>(
              bloc: themeBloc,
              builder: (context, state) {
                return state.theme.name == theme.name
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : const SizedBox.shrink();
              },
            ),
            onPressed: (context) {
              themeBloc.add(ChangeTheme(theme));
            },
          ),
      ],
    );
  }
}
