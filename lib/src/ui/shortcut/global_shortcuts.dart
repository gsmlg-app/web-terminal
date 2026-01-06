import 'package:flutter/material.dart';
import 'package:web_terminal/src/ui/shortcut/intents.dart';
import 'package:web_terminal/src/ui/shortcuts.dart' as shortcuts;

class GlobalShortcuts extends StatelessWidget {
  const GlobalShortcuts({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        shortcuts.openNewWindow: const NewWindowIntent(),
      },
      child: child,
    );
  }
}
