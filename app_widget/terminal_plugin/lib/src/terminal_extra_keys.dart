import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart';

/// Touch keys for terminal input without moving focus away from the terminal.
class TerminalExtraKeys extends StatelessWidget {
  const TerminalExtraKeys({
    super.key,
    required this.ctrlPressed,
    required this.altPressed,
    required this.onToggleCtrl,
    required this.onToggleAlt,
    required this.onKey,
  });

  final bool ctrlPressed;
  final bool altPressed;
  final VoidCallback onToggleCtrl;
  final VoidCallback onToggleAlt;
  final ValueChanged<TerminalKey> onKey;

  static const _keys = <(String, TerminalKey?)>[
    ('ESC', TerminalKey.escape),
    ('TAB', TerminalKey.tab),
    ('CTRL', null),
    ('ALT', null),
    ('HOME', TerminalKey.home),
    ('END', TerminalKey.end),
    ('PGUP', TerminalKey.pageUp),
    ('←', TerminalKey.arrowLeft),
    ('↓', TerminalKey.arrowDown),
    ('↑', TerminalKey.arrowUp),
    ('→', TerminalKey.arrowRight),
    ('PGDN', TerminalKey.pageDown),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: ExcludeFocus(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 12 * 48 ? 12 : 6;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var start = 0; start < _keys.length; start += columns)
                  Row(
                    children: [
                      for (final (label, terminalKey)
                          in _keys.skip(start).take(columns))
                        Expanded(
                          child: _buildKey(context, label, terminalKey),
                        ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildKey(
    BuildContext context,
    String label,
    TerminalKey? terminalKey,
  ) {
    final colors = Theme.of(context).colorScheme;
    final bool? toggled = switch (label) {
      'CTRL' => ctrlPressed,
      'ALT' => altPressed,
      _ => null,
    };
    final onPressed = terminalKey != null
        ? () => onKey(terminalKey)
        : label == 'CTRL'
            ? onToggleCtrl
            : onToggleAlt;

    return Semantics(
      label: label,
      button: true,
      toggled: toggled,
      onTap: onPressed,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        excludeFromSemantics: true,
        child: Ink(
          color: toggled == true
              ? colors.secondaryContainer
              : colors.surfaceContainerLow,
          child: InkWell(
            canRequestFocus: false,
            excludeFromSemantics: true,
            onTap: onPressed,
            child: SizedBox(
              height: 48,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: toggled == true
                              ? colors.onSecondaryContainer
                              : colors.onSurface,
                          fontWeight: toggled == true
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
