import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:web_terminal/screens/settings/settings_screen.dart';
import 'package:web_terminal/screens/terminal/terminal_screen.dart';
import 'package:web_terminal/src/extensions/buildcontext/l10n.dart';

class Destinations {
  static List<NavigationDestination> navs(BuildContext context) =>
      <NavigationDestination>[
        NavigationDestination(
          key: const Key(TerminalScreen.name),
          icon: const Icon(Icons.terminal_outlined),
          selectedIcon: const Icon(Icons.terminal),
          label: context.l10n.destinationTerminal,
        ),
        NavigationDestination(
          key: const Key(SettingsScreen.name),
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings),
          label: context.l10n.destinationSetting,
        ),
      ];

  static int indexOf(Key key, BuildContext context) {
    return navs(context).indexWhere((element) => element.key == key);
  }

  static void changeHandler(int idx, BuildContext context) {
    void _ = switch (idx) {
      0 => context.goNamed(TerminalScreen.name),
      1 => context.goNamed(SettingsScreen.name),
      int() => context.goNamed(TerminalScreen.name),
    };
  }
}
