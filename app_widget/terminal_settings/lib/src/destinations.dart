import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_locale/app_locale.dart';

/// Navigation destinations configuration for the terminal app.
///
/// This class provides methods to build navigation destinations and handle
/// navigation changes. Screen names and paths should be provided by the app.
class Destinations {
  /// Terminal screen name constant - should match the app's routing configuration.
  static const String terminalScreenName = 'TerminalScreen';

  /// Settings screen name constant - should match the app's routing configuration.
  static const String settingsScreenName = 'Settings';

  /// Builds navigation destinations for the app.
  ///
  /// Returns a list of [NavigationDestination] widgets for terminal and settings.
  static List<NavigationDestination> navs(BuildContext context) =>
      <NavigationDestination>[
        NavigationDestination(
          key: const Key(terminalScreenName),
          icon: const Icon(Icons.terminal_outlined),
          selectedIcon: const Icon(Icons.terminal),
          label: context.l10n.destinationTerminal,
        ),
        NavigationDestination(
          key: const Key(settingsScreenName),
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings),
          label: context.l10n.destinationSetting,
        ),
      ];

  /// Returns the index of a navigation destination by its key.
  static int indexOf(Key key, BuildContext context) {
    return navs(context).indexWhere((element) => element.key == key);
  }

  /// Handles navigation changes based on the selected index.
  ///
  /// The [idx] parameter is the index of the selected navigation destination.
  /// The [screenNames] parameter is a list of screen names to navigate to,
  /// corresponding to each index.
  static void changeHandler(
    int idx,
    BuildContext context, {
    List<String>? screenNames,
  }) {
    final names = screenNames ?? [terminalScreenName, settingsScreenName];
    if (idx >= 0 && idx < names.length) {
      context.goNamed(names[idx]);
    } else {
      context.goNamed(names.first);
    }
  }
}
