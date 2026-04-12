import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'terminal_app_bar.dart';

/// Result of the tab switcher dialog.
sealed class TabSwitcherResult {}

/// User selected a tab to switch to.
class TabSwitcherSelect extends TabSwitcherResult {
  final String sessionId;
  TabSwitcherSelect(this.sessionId);
}

/// User requested to close a tab.
class TabSwitcherClose extends TabSwitcherResult {
  final String sessionId;
  TabSwitcherClose(this.sessionId);
}

/// Shows a modal tab switcher grid overlay.
/// Returns a [TabSwitcherResult] or null if dismissed.
Future<TabSwitcherResult?> showTabSwitcher(
  BuildContext context, {
  required List<SessionInfo> sessions,
  required String? currentSessionId,
}) {
  return showDialog<TabSwitcherResult>(
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
  late List<SessionInfo> _sessions;
  final _focusNode = FocusNode();

  int get _cols => max(1, sqrt(_sessions.length).ceil());

  @override
  void initState() {
    super.initState();
    _sessions = List.of(widget.sessions);
    _selectedIndex = _sessions.indexWhere(
      (s) => s.id == widget.currentSessionId,
    );
    if (_selectedIndex < 0) _selectedIndex = 0;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _closeSelectedTab() async {
    if (_sessions.isEmpty) return;

    final session = _sessions[_selectedIndex];

    if (session.isRunning) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Close Tab?'),
          content: Text(
            'The session "${session.name}" has a running process. '
            'Are you sure you want to close it?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Close'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    Navigator.of(context).pop(TabSwitcherClose(session.id));
  }

  void _moveTo(int newIndex) {
    if (newIndex >= 0 && newIndex < _sessions.length) {
      setState(() => _selectedIndex = newIndex);
    }
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final cols = _cols;
    final row = _selectedIndex ~/ cols;
    final col = _selectedIndex % cols;

    // Navigate down: Arrow Down / j
    if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
        event.logicalKey == LogicalKeyboardKey.keyJ) {
      _moveTo((row + 1) * cols + col);
      return KeyEventResult.handled;
    }

    // Navigate up: Arrow Up / k
    if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
        event.logicalKey == LogicalKeyboardKey.keyK) {
      _moveTo((row - 1) * cols + col);
      return KeyEventResult.handled;
    }

    // Navigate right: Arrow Right / l
    if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
        event.logicalKey == LogicalKeyboardKey.keyL) {
      _moveTo(row * cols + col + 1);
      return KeyEventResult.handled;
    }

    // Navigate left: Arrow Left / h
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.keyH) {
      _moveTo(row * cols + col - 1);
      return KeyEventResult.handled;
    }

    // Select: Enter
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      Navigator.of(
        context,
      ).pop(TabSwitcherSelect(_sessions[_selectedIndex].id));
      return KeyEventResult.handled;
    }

    // Cancel: Escape
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
      return KeyEventResult.handled;
    }

    // Close tab: Cmd+Backspace (macOS) / Ctrl+Backspace (Linux/Win)
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      final isApple = defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.iOS;
      final mod =
          isApple
              ? HardwareKeyboard.instance.isMetaPressed
              : HardwareKeyboard.instance.isControlPressed;
      if (mod) {
        _closeSelectedTab();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isApple =
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.iOS;
    final deleteHint = isApple ? '⌘⌫ Close' : 'Ctrl+⌫ Close';
    final cols = _cols;

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _onKeyEvent,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 520),
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
                  child: GridView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(8),
                    itemCount: _sessions.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                      childAspectRatio: 1.6,
                    ),
                    itemBuilder: (context, index) {
                      final session = _sessions[index];
                      final isSelected = index == _selectedIndex;
                      final isCurrent = session.id == widget.currentSessionId;

                      return GestureDetector(
                        onTap: () => Navigator.of(context).pop(
                          TabSwitcherSelect(session.id),
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primaryContainer
                                : colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                            border: isCurrent
                                ? Border.all(
                                    color: colorScheme.primary,
                                    width: 2,
                                  )
                                : null,
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.terminal,
                                size: 24,
                                color: isSelected
                                    ? colorScheme.onPrimaryContainer
                                    : colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                session.name,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isSelected
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onSurface,
                                  fontWeight: isCurrent
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${index + 1}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isSelected
                                      ? colorScheme.onPrimaryContainer
                                          .withValues(alpha: 0.7)
                                      : colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.7),
                                ),
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
                    'hjkl/←↓↑→ Navigate  ↵ Select  $deleteHint  Esc Cancel',
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
