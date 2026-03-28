import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'terminal_app_bar.dart';

/// Shows a modal tab switcher overlay.
/// Returns the selected session ID, or null if dismissed.
Future<String?> showTabSwitcher(
  BuildContext context, {
  required List<SessionInfo> sessions,
  required String? currentSessionId,
}) {
  return showDialog<String>(
    context: context,
    barrierColor: Colors.black54,
    builder: (context) => _TabSwitcherDialog(
      sessions: sessions,
      currentSessionId: currentSessionId,
    ),
  );
}

class _TabSwitcherDialog extends StatefulWidget {
  const _TabSwitcherDialog({
    required this.sessions,
    required this.currentSessionId,
  });

  final List<SessionInfo> sessions;
  final String? currentSessionId;

  @override
  State<_TabSwitcherDialog> createState() => _TabSwitcherDialogState();
}

class _TabSwitcherDialogState extends State<_TabSwitcherDialog> {
  late int _selectedIndex;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.sessions.indexWhere(
      (s) => s.id == widget.currentSessionId,
    );
    if (_selectedIndex < 0) _selectedIndex = 0;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        _selectedIndex = (_selectedIndex + 1) % widget.sessions.length;
      });
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _selectedIndex =
            (_selectedIndex - 1 + widget.sessions.length) %
            widget.sessions.length;
      });
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter) {
      Navigator.of(context).pop(widget.sessions[_selectedIndex].id);
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _onKeyEvent,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 480),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: colorScheme.surfaceContainer,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Switch Tab',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: widget.sessions.length,
                    itemBuilder: (context, index) {
                      final session = widget.sessions[index];
                      final isSelected = index == _selectedIndex;
                      final isCurrent = session.id == widget.currentSessionId;

                      return InkWell(
                        onTap: () => Navigator.of(context).pop(session.id),
                        child: Container(
                          color: isSelected
                              ? colorScheme.primaryContainer
                              : null,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 24,
                                child: Text(
                                  '${index + 1}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.terminal,
                                size: 18,
                                color: isSelected
                                    ? colorScheme.onPrimaryContainer
                                    : colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  session.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isSelected
                                        ? colorScheme.onPrimaryContainer
                                        : colorScheme.onSurface,
                                    fontWeight: isCurrent
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (isCurrent)
                                Icon(
                                  Icons.check,
                                  size: 18,
                                  color: isSelected
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.primary,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    '↑↓ Navigate  ↵ Select  Esc Cancel',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
