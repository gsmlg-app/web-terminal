import 'dart:async';
import 'dart:convert';

import 'package:context_menus/context_menus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_plugin/src/terminal_menu.dart';
import 'package:terminal_plugin/src/terminal_shortcut_handler.dart';
import 'package:terminal_settings_bloc/terminal_settings_bloc.dart';
import 'package:xterm/xterm.dart';

class TerminalPlugin extends Plugin {
  final terminal = Terminal(
    maxLines: 10000,
    batchWrites: true, // Enable write batching for better performance
  );

  final terminalController = TerminalController();

  /// Error message from connection failure, displayed as selectable text.
  final connectionError = ValueNotifier<String?>(null);

  var terminalTitle = '';

  ExecutionSession? session;

  Timer? _resizeTitleTimer;

  void _updateTitle() {
    if (session != null) {
      title.value =
          '$terminalTitle — ${terminal.viewWidth}x${terminal.viewHeight}';
    }
  }

  @override
  void didMounted() {
    title.value = 'Connecting';

    terminal.onTitleChange = (title) {
      terminalTitle = title;
      _updateTitle();
    };

    terminal.onOutput = (data) {
      session?.write(const Utf8Encoder().convert(data));
    };

    terminal.onResize = (w, h, pw, ph) {
      session?.resize(w, h);
      // Debounce title update during resize to avoid excessive rebuilds
      // that can overwhelm the EGL rendering pipeline on Linux.
      _resizeTitleTimer?.cancel();
      _resizeTitleTimer = Timer(const Duration(milliseconds: 100), () {
        _updateTitle();
      });
    };

    super.didMounted();
  }

  @override
  void didConnected() async {
    title.value = 'Terminal';

    try {
      session = await host.shell(
        width: terminal.viewWidth,
        height: terminal.viewHeight,
      );

      // Add welcome message
      terminal.write('\r\nWelcome to Web Terminal!\r\n');
      terminal
          .write('Type "help" for available commands or start typing...\r\n\r\n');

      session!.output
          .cast<List<int>>()
          .transform(const Utf8Decoder())
          .listen((data) {
        terminal.write(data);
        session?.ackRead(); // Acknowledge read for flow control
      });

      session!.exitCode.then((code) {
        session = null;
        if (mounted) {
          manager.remove(this);
        }
      });
    } catch (e) {
      terminal.write('\r\n\x1b[31mError: Failed to start shell: $e\x1b[0m\r\n');
    }
  }

  @override
  void didDisconnected() {
    _resizeTitleTimer?.cancel();
    session = null;
    title.value = 'Disconnected';
  }

  @override
  void onConnectionStatus(HostConnectorStatus status) {
    switch (status) {
      case HostConnectorStatus.connecting:
        title.value = 'Connecting';
        break;
      case HostConnectorStatus.connected:
        title.value = 'Terminal';
        break;
      case HostConnectorStatus.disconnected:
        title.value = 'Disconnected';
        break;
      default:
    }
  }

  @override
  void onConnectionError(Object error) {
    title.value = 'Connection Failed';
    connectionError.value = '$error';
  }

  @override
  Widget build(BuildContext context) {
    return TerminalTabView(this);
  }
}

class TerminalTabView extends StatefulWidget {
  const TerminalTabView(this.plugin, {super.key});

  final TerminalPlugin plugin;

  @override
  State<StatefulWidget> createState() => _TerminalTabViewState();
}

class _TerminalTabViewState extends State<TerminalTabView> {
  final _terminalFocusNode = FocusNode(debugLabel: 'TerminalViewFocus');
  ValueNotifier<int>? _focusNotifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newNotifier = TerminalShortcutHandler.of(context)?.focusNotifier;
    if (newNotifier != _focusNotifier) {
      _focusNotifier?.removeListener(_onFocusRequested);
      _focusNotifier = newNotifier;
      _focusNotifier?.addListener(_onFocusRequested);
    }
  }

  void _onFocusRequested() {
    if (mounted) {
      _terminalFocusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _focusNotifier?.removeListener(_onFocusRequested);
    _terminalFocusNode.dispose();
    widget.plugin.terminal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TerminalSettingsBloc, TerminalSettingsState>(
      builder: (context, state) {
        // Get font settings from state or use defaults
        final fontSize = state is TerminalSettingsLoaded
            ? state.fontSize
            : kTerminalDefaultFontSize;
        final fontFamily = state is TerminalSettingsLoaded
            ? state.fontFamily
            : kTerminalDefaultFontFamily;

        return CupertinoPageScaffold(
          key: ValueKey(widget.plugin),
          backgroundColor: Colors.transparent,
          child: SafeArea(
            child: Stack(
              children: [
                ClipRect(
                  child: TerminalView(
                    widget.plugin.terminal,
                    controller: widget.plugin.terminalController,
                    focusNode: _terminalFocusNode,
                    onKeyEvent: TerminalShortcutHandler.of(context)?.onKeyEvent,
                    onSecondaryTapDown: (_, __) => showMenu(),
                    backgroundOpacity: 0.8,
                    autofocus: true,
                    textStyle: TerminalStyle(
                      fontSize: fontSize,
                      fontFamily: fontFamily,
                    ),
                  ),
                ),
                ValueListenableBuilder<String?>(
                  valueListenable: widget.plugin.connectionError,
                  builder: (context, error, _) {
                    if (error == null) return const SizedBox.shrink();
                    return _ConnectionErrorOverlay(
                      error: error,
                      onRetry: () {
                        widget.plugin.connectionError.value = null;
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showMenu() {
    final menu = TerminalContextMenu(plugin: widget.plugin);
    context.contextMenuOverlay.show(menu);
  }
}

class _ConnectionErrorOverlay extends StatelessWidget {
  const _ConnectionErrorOverlay({
    required this.error,
    required this.onRetry,
  });

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                Text(
                  'Connection Failed',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SelectableText(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onRetry,
                child: const Text('Dismiss'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
